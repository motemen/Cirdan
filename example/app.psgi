use strict;
use warnings;
use lib 'lib';
use Cirdan 'mt';

use Plack::Request;
sub Cirdan::request_class { 'Plack::Request' }

GET '/' => *index;

sub index {
    my ($req) = @_;
    OK mt \*DATA, title => 'index';
}

sub { Cirdan->dispatch(Cirdan->request_class->new(shift)) };

__DATA__
? local %_ =  @_;
<html>
?= $_{title};
unko
</html>
