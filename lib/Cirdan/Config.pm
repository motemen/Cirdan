package Cirdan::Config;
use strict;
use warnings;
use base qw(Class::Data::Inheritable);
use Hash::Merge::Simple qw(merge);
require Exporter::Lite;

our @EXPORT    = qw(config package_config);
our @EXPORT_OK = @EXPORT;
our $Env;

our $Config = {
};

sub import {
    my $class = $_[0];
    if (ref $_[-1] eq 'HASH') {
        $class->setup(pop);
    }
    goto \&Exporter::Lite::import;
}

sub setup {
    my $class = shift;
    $Config = ref $_[0] eq 'HASH' ? $_[0] : { @_ };
    $class->compile;
}

sub compile {
    undef our $Instance;
    foreach (keys %$Config) {
        next if /^default$/;
        $Config->{$_} = merge $Config->{default}, $Config->{$_};
    }
}

sub config ($) {
    __PACKAGE__->load->param($_[0]);
}

sub package_config (;$) {
    my ($package) = caller;

    my $config = __PACKAGE__->load->param($package);
    @_ ? $config->{+shift} : $config;
}

sub load {
    our $Instance ||= shift->_load;
}

sub _load {
    my $class = shift;
    my $env = $Env || 'default';
    bless $Config->{$env}, $class;
}

sub param {
    my ($self, $key) = @_;
    $self->{$key};
}

1;
