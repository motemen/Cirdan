package Cirdan::View;
use strict;
use warnings;

our %Impl;

sub import {
    my $class = shift;
    my $pkg   = caller;
    $class->implant_renderer($pkg, $_) foreach @_;
}

sub impl {
    my ($class, $name) = @_;
    $Impl{$name} ||= do {
        my $package = join '::', __PACKAGE__, uc $name;
        $package->require or die $@;
        $package->new;
    };
}

sub implant_renderer {
    my ($class, $pkg, @names) = @_;

    foreach my $name (@names) {
        no strict 'refs';
        my $impl = $class->impl($name);
        *{"$pkg\::$name"} = sub { $impl->render(@_) };
    }
}

1;
