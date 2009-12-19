Cirdan
======

Synopsis
--------
    use Cirdan; # Exports routing functions, response functions

    POST '/entry'       => *post_entry; # Specify path as string, handler as glob
    GET  '/entry/(\d+)' => *entry;
    ANY  '/'            => *index;
    ANY qr//            => sub { NOT_FOUND }; # Specify path as regexp, handler as coderef

    sub post_entry {
        ...
        return BAD_REQUEST unless ...
        ...
        redirect path_for('index');
    }

    use Cirdan::View qw(mt); # Exports renderer functions

    sub index {
        my $body = mt *DATA, @args;
        return $body;
        # or
        # HTTP status code names are response maker
        # such as CREATED([\@headers,] $content)
        return OK $body;
        return OK [ 'Content-Type' => 'text/xml' ], $body;
    }

    # Finally...
    __PSGI__ # returns PSGI handler

    __END__
