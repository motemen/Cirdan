use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Cirdan::Router::Entry' }

sub post_bar { }

ok my $e1 = Cirdan::Router::Entry->new(path => '/foo', method => 'GET',  code => sub { 'GET /foo' });
ok my $e2 = Cirdan::Router::Entry->new(path => '/bar', method => 'POST', code => *post_bar);
ok my $e3 = Cirdan::Router::Entry->new(path => '/bar', method => undef,  code => sub { 'ANY /bar' });
ok my $e4 = Cirdan::Router::Entry->new(path => qr//,   method => undef,  code => sub { 'ANY /' });
ok my $e5 = Cirdan::Router::Entry->new(path => [ '/foo/', qr/\d+/ ], method => 'GET', code => sub { '/foo/$id' });
ok my $e6 = Cirdan::Router::Entry->new(path => [ '/w/', qr/.+/ ], method => undef, code => sub {});

ok !$e1->name;
is  $e2->name, 'post_bar';
ok !$e3->name;
ok !$e4->name;

like '/foo/2', $e5->regexp;

ok  $e1->handles_method('GET');
ok !$e1->handles_method('POST');
ok  $e3->handles_method('GET');
ok  $e3->handles_method('POST');

ok  $e1->handles_uri('http://localhost/foo');
ok !$e2->handles_uri('http://localhost/foo');
ok !$e1->handles_uri('http://localhost/bar');
ok  $e2->handles_uri('http://localhost/bar');
ok  $e4->handles_uri('http://localhost/foo');
ok  $e4->handles_uri('http://localhost/bar');

is_deeply [ $e5->handles_path('/foo/3') ], [ '/foo/3', '3' ];
is_deeply [ $e6->handles_path('/w/%E3%81%86%E3%82%93%E3%81%93') ]->[1], 'うんこ';
is $e5->make_path(5), '/foo/5';

done_testing;
