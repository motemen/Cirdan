package Cirdan::View::JSON;
use Any::Moose;

extends 'Cirdan::View';

has '+content_type', (
    default => sub { 'application/json' }
);

use JSON::Syck;

sub render {
    my ($class, $object) = @_;
    JSON::Syck::Dump $object;
}

1;
