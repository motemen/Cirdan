package Cirdan;
use strict;
use warnings;
use Cirdan::Router;
use Cirdan::Util::Response;
use Cirdan::Context;

use UNIVERSAL::require;
use Exporter::Lite ();

our @EXPORT = (
    qw(GET POST ANY __PSGI__ path_for req),
    @Cirdan::Util::Response::EXPORT
);

sub import {
    strict->import;
    warnings->import;
    goto \&Exporter::Lite::import;
}

sub request_class { 'Plack::Request' }

sub view    { 'Cirdan::View' }
sub context { 'Cirdan::Context' }

sub default_headers { 'Content-Type' => 'text/html; charset=utf-8' }

sub router { our $Router ||= Cirdan::Router->new }

sub dispatch { shift->router->dispatch(@_) }

sub path_for { __PACKAGE__->router->path_for(@_) }

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

sub req { __PACKAGE__->context->request(@_) }

sub __compile {
    my $class = shift;
    $class->request_class->require or die $@;
}

sub make_psgi_handler {
    my $class = shift;

    return sub {
        my $env = shift;
        my $context = $class->context;

        $context->request($class->request_class->new($env));

        my $res = $class->dispatch($context->request);
        unless (ref $res eq 'ARRAY') {
            $res = OK $res;
        }

        if (my $headers = $context->headers) {
            push @{$res->[1]}, ref $headers eq 'HASH' ? %$headers : @$headers;
        }

        unless (@{$res->[1]}) {
            @{$res->[1]} = $class->default_headers;
        }

        $context->clear;

        $res;
    };
}

sub __PSGI__ {
    __PACKAGE__->__compile;
    __PACKAGE__->make_psgi_handler;
}

1;
