package Cirdan::AnyEvent;
use strict;
use warnings;
use AnyEvent;
use Coro;
use Coro::AnyEvent;
use Exporter::Lite;

require Cirdan;

our @EXPORT_OK = qw(async_response);

sub async_response (&) {
    my $block = shift;
    my $cv = AnyEvent->condvar;
    async {
        my $res = $block->();
        $res = Cirdan->finalize_res($res);
        $cv->send($res);
    };
    $cv;
}

1;

# for Plack::Server::AnyEvent
