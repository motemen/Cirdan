#!perl
use lib 'lib';
use Cirdan;
use Cirdan::View 'mt';

ANY '/' => *index;

sub index {
    my ($req) = @_;
    OK mt *DATA, title => 'index';
}

__PSGI__

__DATA__
? local %_ = @_;
<html>
?= $_{title};
</html>
