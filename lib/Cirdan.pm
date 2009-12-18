package Cirdan;
use strict;
use warnings;
use Cirdan::Router;
use UNIVERSAL::require;
use HTTP::Status ();

our @EXPORT = qw(GET POST ANY);

our $Router;
our %View;

sub router { $Router ||= Cirdan::Router->new }

sub dispatch { shift->router->dispatch(@_) }
sub path_for { shift->router->path_for(@_) }

sub view {
    my ($class, $name) = @_;
    $View{$name} ||= do {
        my $package = join '::', __PACKAGE__, 'View', uc $name;
        $package->require or die $@;
        $package->new;
    };
}

sub import {
    my $class = shift;
    my $pkg   = caller;

    $class->import_renderer($pkg, @_);

    foreach my $method (@EXPORT) {
        no strict 'refs';
        *{"$pkg\::$method"} = __PACKAGE__->can($method);
    }
}

sub import_renderer {
    my ($class, $pkg, @names) = @_;

    foreach my $name (@names) {
        my $code = sub { __PACKAGE__->view($name)->render(@_) };
        no strict 'refs';
        *{"$pkg\::$name"} = $code;
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
*ANY  = _make_routing_function('');

sub _make_response_function {
    my $code = shift;
    return sub {
        my $content = pop;
        return [ $code, { @_ }, $content ];
    };
}

foreach my $constant (@HTTP::Status::EXPORT) {
    (my $name = $constant) =~ s/^RC_// or next;
    no strict 'refs';
    *{ __PACKAGE__ . "::$name" } = _make_response_function(HTTP::Status->can($constant)->());
    push @EXPORT, $name;
}

1;
