package Cirdan::Util::Response;
use strict;
use warnings;
use Cirdan::Context;
use Exporter::Lite;
use HTTP::Status;

our @EXPORT = qw(
    set_cookie redirect
    OK CREATED
    MOVED_PERMANENTLY FOUND
    BAD_REQUEST UNAUTHORIZED FORBIDDEN NOT_FOUND METHOD_NOT_ALLOWED
    INTERNAL_SERVER_ERROR NOT_IMPLEMENTED
);

our @EXPORT_OK;

sub _make_response_function {
    my $status_code = shift;

    return sub {
        my ($headers, $content) = ref $_[0] eq 'ARRAY' ? @_ : ([], @_);

        if (not defined $content) {
            $content = $status_code . ' ' . status_message($status_code);
        }

        [ $status_code, $headers, [ $content ] ];
    };
}

foreach my $constant (@HTTP::Status::EXPORT) {
    (my $name = $constant) =~ s/^RC_// or next;
    no strict 'refs';
    *{ __PACKAGE__ . "::$name" } = _make_response_function(&{"HTTP::Status::$constant"});
    push @EXPORT_OK, $name;
}

sub set_cookie {
    my ($name, $val) = @_;

    require CGI::Simple::Cookie;

    Cirdan::Context->headers([]) unless Cirdan::Context->headers;

    push @{ Cirdan::Context->headers },
         'Set-Cookie' => CGI::Simple::Cookie->new(
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
    FOUND([ Location => $url ], '');
}

1;
