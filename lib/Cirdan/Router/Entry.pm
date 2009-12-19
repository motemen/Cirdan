package Cirdan::Router::Entry;
use Any::Moose;

has 'path', (
    is  => 'rw',
    isa => 'Any',
    required => 1,
);

has 'method', (
    is  => 'rw',
    isa => 'Maybe[Str]',
    required => 1,
);

has 'code', (
    is  => 'rw',
    isa => 'Any', # XXX CodeRef or Glob
    required => 1,
);

has 'name', (
    is  => 'rw',
    isa => 'Maybe[Str]',
    lazy_build => 1,
);

has 'regexp', (
    is  => 'rw',
    isa => 'RegexpRef',
    lazy_build => 1,
);

has 'method_mapping', (
    is  => 'rw',
    isa => 'HashRef',
    lazy_build => 1,
);

sub _build_name {
    my $self = shift;
    return unless ref \$self->code eq 'GLOB';
    *{$self->code}{NAME};
}

sub _build_regexp {
    my $self = shift;
    ref $self->path ? $self->path : qr/^$self->{path}$/;
}

sub _build_method_mapping {
    my $self = shift;
    my $method = $self->method;
    !$method || $method eq '*' || $method eq '_' ? undef :
    ref $method eq 'ARRAY' ? +{ map { uc $_ => 1 } @$method } :
    +{ uc $method => 1 };
}

sub handles_method {
    my $self = shift;
    my $method = shift;
    return 1 unless $self->method_mapping;
    $self->method_mapping->{uc $method};
}

sub handles_uri {
    my $self = shift;
    my $uri  = shift;
    $uri->path =~ $self->regexp or return;

    my @matches;
    for (0 .. $#+) {
        push @matches, substr($uri->path, $-[$_], $+[$_] - $-[$_]);
    }

    @matches;
}

1;
