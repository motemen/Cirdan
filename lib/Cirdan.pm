package Cirdan;
use strict;
use warnings;
use Cirdan::Router;
use Cirdan::Util::Response;

use UNIVERSAL::require;
use Exporter::Lite ();

our @EXPORT = (
    qw(GET POST ANY __PSGI__ path_for set_cookie redirect),
    @Cirdan::Util::Response::EXPORT
);

sub import {
    strict->import;
    warnings->import;
    goto \&Exporter::Lite::import;
}

sub request_class { 'Plack::Request' }
sub view { 'Cirdan::View' }

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

sub set_cookie {
    my ($name, $val) = @_;

    require CGI::Simple::Cookie;

    push @{ __PACKAGE__->context->{additional_headers} }, 
         Set_Cookie => CGI::Simple::Cookie->new(
             -name    => $name,
             -value   => $val->{value},
             -expires => $val->{expires},
             -domain  => $val->{domain},
             -path    => $val->{path},
             -secure  => ( $val->{secure} || 0 )
         )->as_string;
}

sub redirect {
    my ($url) = @_;
    FOUND [ Location => $url ], '';
}

sub __compile {
    my $class = shift;
    $class->request_class->require or die $@;
}

our $Context;

sub context { $Context }

sub make_psgi_handler {
    my $class = shift;

    return sub {
        my $env = shift;

        local $Context = {};

        my $req = $class->request_class->new($env);
        my $res = $class->dispatch($req);

        unless (ref $res eq 'ARRAY') {
            $res = OK $res;
        }

        if ($Context->{additional_headers}) {
            push @{$res->[1]}, @{$Context->{additional_headers}};
        }

        $res;
    };
}

sub __PSGI__ {
    __PACKAGE__->__compile;
    __PACKAGE__->make_psgi_handler;
}

1;
