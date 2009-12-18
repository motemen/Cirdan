package Cirdan::Router;
use strict;
use warnings;
use Any::Moose;

has 'routes', (
    is  => 'rw',
    isa => 'ArrayRef',
    default => sub { +[] },
);

sub add {
    my ($self, $path, $method, $code) = @_;

    my $entry = { path => $path, code => $code };
    $entry->{regexp} = ref $entry->{path} ? $entry->{path} : qr/^$entry->{path}$/;
    $entry->{method} =
        !$method || $method eq '*' || $method eq '_' ? undef :
        ref $method eq 'ARRAY' ? +{ map { uc $_ => 1 } @$method } :
        +{ uc $method => 1 };

    push @{$self->routes}, $entry;
}

sub dispatch {
    my ($self, $req, @args) = @_;

    my $path = $req->uri->path;
    foreach my $entry (@{$self->routes}) {
        next if $entry->{method} && !$entry->{method}->{uc $req->method};
        next unless $path =~ $entry->{regexp};
        return $entry->{code}->($req, @args);
    }
}

sub path_for {
    my ($self, $name) = @_;

    foreach my $entry (@{$self->routes}) {
        if (ref \$entry->{code} eq 'GLOB'
                && *{$entry->{code}}{NAME} eq $name) {
            return $entry->{path};
        }
    }
}

1;
