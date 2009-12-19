package Cirdan::Context;
use strict;
use warnings;

our @Symbols = qw(request headers route);

sub __compile {
    foreach my $symbol (@Symbols) {
        no strict 'refs';
        *{ __PACKAGE__ . "::$symbol" } = sub {
            my $class = shift;
            ${"$class\::$symbol"} = shift if @_;
            ${"$class\::$symbol"};
        };
    }
}

sub clear {
    my $class = shift;
    foreach my $symbol (@Symbols) {
        no strict 'refs';
        undef ${"$class\::$symbol"};
    }
}

__PACKAGE__->__compile;

1;
