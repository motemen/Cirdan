package Cirdan;
use strict;
use warnings;
use Cirdan::Router;
use Cirdan::Util::Response;

use UNIVERSAL::require;
use Exporter::Lite;

our @EXPORT = (qw(GET POST ANY __PSGI__), @Cirdan::Util::Response::EXPORT);

sub request_class { 'Plack::Request' }
sub view { 'Cirdan::View' }

our $Router;

sub router { $Router ||= Cirdan::Router->new }

sub dispatch { shift->router->dispatch(@_) }
sub path_for { shift->router->path_for(@_) }

{
    no warnings 'redefine';
    sub import {
        strict->import;
        warnings->import;
        goto \&Exporter::Lite::import;
    }
}

sub _make_routing_function {
    my $method = shift;
    return sub {
        my ($path, $code) = @_;
        __PACKAGE__->router->add($path, $method, $code);
    };
}

*GET  = _make_routing_function('GET');
*POST = _make_routing_function('POST');
*ANY  = _make_routing_function(undef);

sub __compile {
    my $class = shift;
    $class->request_class->require or die $@;
}

sub make_psgi_handler {
    my $class = shift;

    return sub {
        my $env = shift;

        my $req = $class->request_class->new($env);
        my $res = $class->dispatch($req);

        unless (ref $res eq 'ARRAY') {
            $res = OK $res;
        }

        $res;
    };
}

sub __PSGI__ {
    __PACKAGE__->__compile;
    __PACKAGE__->make_psgi_handler;
}

1;
