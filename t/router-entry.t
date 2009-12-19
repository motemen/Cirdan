use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Cirdan::Router::Entry' }

sub post_bar { }

ok my $e1 = Cirdan::Router::Entry->new(path => '/foo', method => 'GET',  code => sub { 'GET /foo' });
ok my $e2 = Cirdan::Router::Entry->new(path => '/bar', method => 'POST', code => *post_bar);
ok my $e3 = Cirdan::Router::Entry->new(path => '/bar', method => undef,  code => sub { 'ANY /bar' });
ok my $e4 = Cirdan::Router::Entry->new(path => qr//,   method => undef,  code => sub { 'ANY /' });

ok !$e1->name;
is  $e2->name, 'post_bar';
ok !$e3->name;
ok !$e4->name;

done_testing;
