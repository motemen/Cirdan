package Cirdan::Router::Entry;
use Any::Moose;
use URI;

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
    my $type = lc ref $self->path || 'string';
    my $code = __PACKAGE__->can("_build_regexp_from_$type") or die "Cannot handle $type";
    $code->($self->path);
}

sub _build_regexp_from_regexp {
    my $regexp = shift;
    return $regexp;
}

sub _build_regexp_from_array {
    my $array = shift;
    my $string = '';
    foreach (@$array) {
        $string .= ref $_ eq 'Regexp' ? "($_)" : $_;
    }
    return _build_regexp_from_string($string);
}

sub _build_regexp_from_string {
    my $string = shift;
    return qr/^$string$/;
}

sub _build_method_mapping {
    my $self = shift;
    my $method = $self->method;
    return undef if !$method || $method eq '*' || $method eq '_';
    ref $method eq 'ARRAY' ? +{ map { uc $_ => 1 } @$method } : +{ uc $method => 1 };
}

sub handles_method {
    my $self   = shift;
    my $method = shift;
    return 1 unless $self->method_mapping;
    $self->method_mapping->{uc $method};
}

sub handles_uri {
    my $self = shift;
    my $uri  = shift;
    $uri = URI->new($uri) unless ref $uri;
    $self->handles_path($uri->path);
}

sub handles_path {
    my $self = shift;
    my $path = shift;

    $path =~ $self->regexp or return;

    my @matches;
    for (0 .. $#+) {
        push @matches, substr($path, $-[$_], $+[$_] - $-[$_]);
    }

    @matches;
}

sub make_path {
    my $self = shift;
    my @args = @_;

    if (ref $self->path eq 'ARRAY') {
        return $self->_make_path_array(@args);
    } else {
        return $self->_make_path_string(@args);
    }
}

sub _make_path_array {
    my ($self, @args) = @_;

    my $path = '';
    foreach (@{$self->path}) {
        if (ref $_) {
            $path .= shift @args;
        } else {
            $path .= $_;
        }
    }
    $path;
}

sub _make_path_string {
    my ($self, @args) = @_;

    my $path = $self->path;
    while (@args) {
        $path =~ s{\(.+?\)}{ shift @args }e;
    }
    $path;
}

1;
