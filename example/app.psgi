#!perl
use lib 'lib';
use Cirdan;
use Cirdan::View 'mt';

POST '/entry' => *post_entry;
ANY  '/'      => *index;
ANY  qr//     => sub { NOT_FOUND };

my @entries;

sub post_entry {
    my $req = shift;
    my $text = $req->param('text');
    return BAD_REQUEST unless length $text;

    unshift @entries, $text;
    redirect path_for('index');
}

sub index {
    my $req = shift;
    mt *DATA, title => 'index', entries => \@entries;
}

__PSGI__

__DATA__
? local %_ = @_;
<html>
<head><title><?= $_{title} ?></title></head>
<body>
<form action="<?= Cirdan::path_for('post_entry') ?>" method="POST">
<input type="text" name="text">
<input type="submit">
</form>
<ul>
? foreach (@{$_{entries}}) {
<li><?= $_ ?></li>
? }
</ul>
</body>
</html>
