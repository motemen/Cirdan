package Cirdan::Util;
use strict;
use warnings;
use URI;
use Exporter;

our @EXPORT_OK = qw(uri_for);

sub uri_for {
    require Cirdan;
    my $uri = Cirdan->context->request->uri;
    URI->new_abs(Cirdan->router->path_for(@_), $uri);
}

1;
