use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Cirdan::Util::Response' }

can_ok __PACKAGE__, qw(OK FOUND FORBIDDEN NOT_IMPLEMENTED);

is_deeply OK,                [ 200, [], ['200 OK'] ];
is_deeply OK('Hello world'), [ 200, [], ['Hello world'] ];

is_deeply FOUND([ Location => 'http://localhost/' ]),             [ 302, [ Location => 'http://localhost/' ], ['302 Found'] ];
is_deeply FOUND([ Location => 'http://localhost/' ], 'Redirect'), [ 302, [ Location => 'http://localhost/' ], ['Redirect'] ];

done_testing;
