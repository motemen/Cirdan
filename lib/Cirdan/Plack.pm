package Cirdan::Plack;
use strict;
use warnings;
use Plack;
use Plack::Loader;
use Carp;

require Cirdan;

our @EXPORT = qw(plackup);

sub plackup {
    my ($backend, $args) = @_;
    my $server = Plack::Loader->load($backend, %$args);
    $server->run(Cirdan->psgi);
}

1;
