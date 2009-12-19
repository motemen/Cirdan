package Cirdan;
use strict;
use warnings;
use Cirdan::Router;
use Cirdan::Util::Response;
use Cirdan::Context;

use UNIVERSAL::require;
use Exporter::Lite ();

our @EXPORT = (
    qw(GET POST ANY __PSGI__ path_for),
    @Cirdan::Util::Response::EXPORT
);

sub import {
    strict->import;
    warnings->import;
    goto \&Exporter::Lite::import;
}

sub request_class { 'Plack::Request' }
sub default_headers { 'Content-Type' => 'text/html; charset=utf-8' }

sub view    { 'Cirdan::View' }
sub context { 'Cirdan::Context' }
sub router  { our $Router ||= Cirdan::Router->new }

sub dispatch { shift->router->dispatch(@_) }
sub path_for { __PACKAGE__->router->path_for(@_) }

{
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
}

sub _finalize_res_headers {
    my ($class, $res) = @_;

    my $res_headers = $res->[1];

    unless (@$res_headers) {
        @$res_headers = $class->default_headers;
    }

    if (my $headers = $class->context->headers) {
        push @$res_headers, ref $headers eq 'HASH' ? %$headers : @$headers;
    }
}

sub __compile {
    my $class = shift;
    $class->request_class->require or die $@;
}

sub make_psgi_handler {
    my $class = shift;

    return sub {
        my $env = shift;
        my $context = $class->context;

        my $req = $context->request = $class->request_class->new($env);

        my $res = $class->dispatch($req);
        $res = OK $res unless ref $res eq 'ARRAY';

        $context->clear;

        $class->_finalize_res_headers($res);
        $res;
    };
}

sub __PSGI__ {
    __PACKAGE__->__compile;
    __PACKAGE__->make_psgi_handler;
}

1;
