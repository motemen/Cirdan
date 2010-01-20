use strict;
use warnings;

use Coro;
use Coro::LWP;

use WWW::NicoVideo::Download;
use HTML::TreeBuilder::XPath;
use HTTP::Request;
use LWP::MediaTypes qw(media_suffix);
use Config::Pit;
use Path::Class qw(dir);
use Perl6::Say;

use lib 'lib';
use Cirdan;
use Cirdan::View qw(mt json);
use Cirdan::AnyEvent;
use Cirdan::Plack;

routes {
    POST '/download'    => *download;
    GET  '/status.json' => *status_json;
    GET  '/'            => *default;
    ANY  qr/./          => sub { NOT_FOUND };
};

my $config = pit_get('nicovideo.jp', require => {
    username => 'email of nicovideo.jp',
    password => 'password of nicovideo.jp',
});

my $download_dir = dir('.');

my $X = sub { HTML::TreeBuilder::XPath->new_from_content($_[0])->findvalue($_[1]) };

my %jobs;

sub download {
    my $req = shift;
    my $url = $req->param('url') or return BAD_REQUEST;
    my ($video_id) = $url =~ m</([^/]+)$>;

    say STDERR "URL: $url";
    say STDERR "video_id: $video_id";

    $jobs{$url} ||= do {
        my $coro = async {
            my $nicovideo = WWW::NicoVideo::Download->new(
                email    => $config->{username},
                password => $config->{password},
            );

            my $name = $video_id;
            my $res = $nicovideo->user_agent->get($url);
            if ($res->is_success) {
                my $title = $X->($res->content, '//h1');
                $name .= " - $title";
            }

            $jobs{$url}{name} = $name;
            say STDERR "name: $name";

            my $fh;
            my $media_url = $nicovideo->prepare_download($video_id);
            $jobs{$url}{media_url} = $media_url;

            $nicovideo->user_agent->request(
                HTTP::Request->new(GET => $media_url), sub {
                    my ($data, $res) = @_;

                    unless ($fh) {
                        my $ext = media_suffix($res->header('Content-Type'));
                        my $file = $download_dir->file("$name.$ext");
                        $fh = $file->openw;
                    }

                    print $fh $data;

                    $jobs{$url}{content_length} = $res->header('Content-Length');
                    $jobs{$url}{data_received}  += length $data;
                }
            );

            delete $jobs{$url};
            say STDERR "done: $url";
        };

        +{ coro => $coro, started => time() };
    };

    redirect +Cirdan->router->path_for('default');
}

sub status_json {
    my $req = shift;

    async_response {
        sleep 1;
        json [ { jobs => \%jobs, type => 'status' } ];
    };
}

sub default {
    my $req = shift;
    mt \*DATA;
}

plackup AnyEvent => { port => 30000 };

__DATA__
? local %_ = @_;
<html>
  <head>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.0/jquery.min.js"></script>
    <script type="text/javascript" src="http://github.com/beppu/jquery-ev/raw/master/jquery.ev.js"></script>
    <script type="text/javascript">
$(function () {
  $.ev.loop(
    '/status.json', {
      status: function (json) {
        $('#jobs').empty();
        var jobs = json.jobs;
        for (var url in jobs) {
          var job = jobs[url];
          var link = $('<a/>').attr({ href: url }).text(job.name || url);
          var info = $('<span/>').attr({ className: 'info' }).text(job.data_received + '/' + job.content_length);
          var li = $('<li/>');
          link.appendTo(li);
          info.appendTo(li);
          li.appendTo($('#jobs'));
        }
      }
    }
  );
});
    </script>
    <style type="text/css">
span.info { color: silver; margin-left: 1em; }
    </style>
  </head>
  <body>
    <form id="download-form" method="post" action="<?= Cirdan->router->path_for('download') ?>">
      <input type="text" name="url" size="40">
      <input type="submit" value="download">
    </form>
    <ul id="jobs">
    </ul>
  </body>
</html>
