use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Cirdan::Util::Response' }

can_ok __PACKAGE__, qw(OK FOUND FORBIDDEN NOT_IMPLEMENTED set_cookie redirect);

is_deeply OK,                [ 200, [], ['200 OK'] ];
is_deeply OK('Hello world'), [ 200, [], ['Hello world'] ];

is_deeply FOUND([ Location => 'http://localhost/' ]),             [ 302, [ Location => 'http://localhost/' ], ['302 Found'] ];
is_deeply FOUND([ Location => 'http://localhost/' ], 'Redirect'), [ 302, [ Location => 'http://localhost/' ], ['Redirect'] ];

set_cookie key => { value => 'value' };
is_deeply +Cirdan::Context->headers, [ 'Set-Cookie' => 'key=value; path=/' ];

is_deeply redirect('http://www.example.com/'), [ 302, [ Location => 'http://www.example.com/' ], [''] ];

done_testing;
