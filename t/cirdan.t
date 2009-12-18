use strict;
use warnings;
use Test::More;
use Test::Exception;
use HTTP::Request::Common ();

BEGIN { *http:: = *HTTP::Request::Common:: }

BEGIN { use_ok 'Cirdan' }

can_ok __PACKAGE__, qw(GET POST ANY __PSGI__ OK NOT_FOUND);

lives_ok {
    GET  '/foo' => sub { 'GET /foo' };
    POST '/bar' => *post_bar;
    ANY  '/bar' => sub { 'ANY /bar' };
    ANY  qr//   => sub { 'ANY /'    };
};

sub post_bar { '&post_bar' }

is     scalar @{Cirdan->router->routes}, 4;
isa_ok +Cirdan->router, 'Cirdan::Router';
is     path_for('post_bar'), '/bar';

done_testing;
