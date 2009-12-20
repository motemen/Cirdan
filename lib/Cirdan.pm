package Cirdan;
use strict;
use warnings;
use Cirdan::Router;
use Cirdan::Context;
use Cirdan::Util::Response;

use UNIVERSAL::require;
use Exporter::Lite ();

our @EXPORT = (
    qw(__PSGI__ routes),
    @Cirdan::Util::Response::EXPORT
);

sub import {
    my $pkg = caller;
    eval qq{
        package $pkg;
        use subs qw(GET POST ANY)
    };
    strict->import;
    warnings->import;
    goto \&Exporter::Lite::import;
}

sub request_class { 'Plack::Request' }
sub default_headers { 'Content-Type' => 'text/html; charset=utf-8' }

sub view    { 'Cirdan::View' }
sub context { 'Cirdan::Context' }
sub router  { our $Router ||= Cirdan::Router->new }

sub routes (&) {
    my $block = shift;
    my $pkg   = caller;

    no strict 'refs';
    local *{"$pkg\::GET"}  = __PACKAGE__->router->make_routing_function('GET');
    local *{"$pkg\::POST"} = __PACKAGE__->router->make_routing_function('POST');
    local *{"$pkg\::ANY"}  = __PACKAGE__->router->make_routing_function(undef);

    $block->();
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
        my $req = $class->context->request = $class->request_class->new($env);

        my $res = $class->router->dispatch($req);
        $res = OK $res unless ref $res eq 'ARRAY';

        $class->_finalize_res_headers($res);
        $class->context->clear;

        $res;
    };
}

sub __PSGI__ {
    __PACKAGE__->__compile;
    __PACKAGE__->make_psgi_handler;
}

1;
