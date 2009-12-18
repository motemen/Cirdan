use strict;
use warnings;
use Test::More;
use Test::Exception;
use HTTP::Request::Common ();

BEGIN { *http:: = *HTTP::Request::Common:: }

BEGIN { use_ok 'Cirdan' }

can_ok __PACKAGE__, qw(GET POST ANY);

lives_ok {
    GET  '/foo' => sub { 'GET /foo' };
    POST '/bar' => *post_bar;
    ANY  '/bar' => sub { 'ANY /bar' };
    ANY  qr//   => sub { 'ANY /'    };
};

sub post_bar { '&post_bar' }

is     scalar @{Cirdan->router->routes}, 4;
isa_ok +Cirdan->router, 'Cirdan::Router';
is     +Cirdan->path_for('post_bar'), '/bar';

Cirdan->import_renderer(__PACKAGE__, 'mt');

can_ok __PACKAGE__, 'mt';

isa_ok +Cirdan->view('mt'), 'Cirdan::View::MT';

done_testing;
