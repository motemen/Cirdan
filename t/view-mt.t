use strict;
use warnings;
use Test::More;
use Test::Exception;

BEGIN { use_ok 'Cirdan::View::MT' }

my $view = Cirdan::View::MT->new;
is   $view->render(*DATA, foo => 'FOO'), "2\nFOO\n";
like $view->render(__FILE__, foo => 'FOO'), qr/^use strict;\n/;

done_testing;

__DATA__
? local %_ = @_;
?= 1+1;
?= $_{foo};
