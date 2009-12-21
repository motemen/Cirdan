#!perl
use lib 'lib';
use Cirdan;
use Cirdan::View qw(mt json);

routes {
    POST q </entry>           => *post_entry;
    ANY  q </entry/>, qr<\d+> => *entry;
    ANY  q </>,               => *index;
    ANY  q </index>,          => *index;
    ANY  q </index.json>      => *index_json;
    ANY  qr<>                 => sub { NOT_FOUND };
};

# Cirdan->view('mt')->content_type('text/plain');

my @entries;

sub post_entry {
    my $req = shift;
    my $text = $req->param('text');
    return BAD_REQUEST unless length $text;

    push @entries, $text;
    redirect +Cirdan->router->path_for('index');
}

sub entry {
    my ($req, $id) = @_;
    my $entry = $entries[$id];
    mt *DATA, entry => $entry;
}

sub index {
    my $req = shift;
    mt *DATA, entries => \@entries;
}

sub index_json {
    my $req = shift;
    json \@entries;
}

__PSGI__

__DATA__
? local %_ = @_;
<html>
  <head><title><?= Cirdan->context->route->name ?></title></head>
  <body>
? if (Cirdan->context->route->name eq 'entry') {
    <div><?= $_{entry} ?></div>
? } else {
    <form action="<?= Cirdan->router->path_for('post_entry') ?>" method="POST">
      <input type="text" name="text">
      <input type="submit">
    </form>
    <ul>
?   foreach (0 .. $#{$_{entries}}) {
      <li><a href="<?= Cirdan->router->path_for('entry', $_) ?>"><?= $_{entries}[$_] ?></a></li>
?   }
? }
    </ul>
  </body>
</html>
