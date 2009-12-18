package Cirdan::Context;
use strict;
use warnings;

our $Request;
our $Headers;

sub request  {
    my $class = shift;
    $Request = shift if @_;
    $Request;
}

sub headers {
    my $class = shift;
    $Headers = shift if @_;
    $Headers;
}

sub clear {
    undef $Request;
    undef $Headers;
}

1;
