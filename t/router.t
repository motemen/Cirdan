use strict;
use warnings;
use Test::More;
use Test::Exception;
use HTTP::Request::Common ();

BEGIN { *http:: = *HTTP::Request::Common:: }

BEGIN { use_ok 'Cirdan::Router' }

my $router = Cirdan::Router->new;
$router->add('/foo', 'GET',  sub { 'GET /foo' });
$router->add('/bar', 'POST', *post_bar);
$router->add('/bar', undef,  sub { 'ANY /bar' });
$router->add(qr//,   undef,  sub { 'ANY /' });

sub post_bar { '&post_bar' }

is scalar @{$router->routes}, 4;

is $router->dispatch(http::GET  '/foo'), 'GET /foo';
is $router->dispatch(http::POST '/foo'), 'ANY /';
is $router->dispatch(http::POST '/bar'), '&post_bar';
is $router->dispatch(http::GET  '/bar'), 'ANY /bar';

is $router->path_for('post_bar'), '/bar';

done_testing;
