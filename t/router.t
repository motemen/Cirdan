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
$router->add([ '/foo/', qr/\d+/ ], undef, *foo);
$router->add(qr//,   undef,  sub { 'ANY /' });

sub post_bar { '&post_bar' }
sub foo { $_[1] }

is scalar @{$router->routes}, 5;

is $router->dispatch(http::GET  '/foo'),   'GET /foo';
is $router->dispatch(http::POST '/foo'),   'ANY /';
is $router->dispatch(http::POST '/bar'),   '&post_bar';
is $router->dispatch(http::GET  '/bar'),   'ANY /bar';
is $router->dispatch(http::GET  '/foo/1'), '1';

is $router->path_for('post_bar'), '/bar';
is $router->path_for('foo', 2), '/foo/2';

done_testing;
