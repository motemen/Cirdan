use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Cirdan::Config' }

can_ok __PACKAGE__, qw(config package_config);

Cirdan::Config->setup(
    default => { foo => 1, bar => 'xxx', 't::config' => { hoge => [1,2,3] } },
    test    => { foo => 7 },
);

is config('foo'), 1;
is config('bar'), 'xxx';

{
    local $Cirdan::Config::Env = 'test';
    compile Cirdan::Config;

    is config('foo'), 7;
    is config('bar'), 'xxx';
}

{
    package t::config;
    use Test::More;
    eval q{ use Cirdan::Config; 1 } or die $@;
    is_deeply package_config(),       { hoge => [1,2,3] };
    is_deeply package_config('hoge'), [1,2,3];
}

done_testing;
