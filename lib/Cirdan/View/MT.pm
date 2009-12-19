package Cirdan::View::MT;
use Any::Moose;
use Text::MicroTemplate qw(build_mt);
use Text::MicroTemplate::File;
use Encode qw(is_utf8 _utf8_off);

has 'mtf', (
    is  => 'rw',
    isa => 'Text::MicroTemplate::File',
    lazy_build => 1,
);

sub _build_mtf {
    Text::MicroTemplate::File->new;
}

my %RENDERER_CACHE;

sub render {
    my ($self, $template, @args) = @_;

    my $content;
    if (ref $template eq 'GLOB' || ref \$template eq 'GLOB') {
        my $renderer = $RENDERER_CACHE{0 + *{$template}{IO}}
            ||= build_mt(do { local $/; scalar <$template> });
        $content = $renderer->(@args)->as_string;
    } else {
        $content = $self->mtf->render_file($template, @args)->as_string;
    }

    _utf8_off $content if is_utf8 $content;

    $content;
}

# XXX
*path_for = \&Cirdan::path_for;

1;
