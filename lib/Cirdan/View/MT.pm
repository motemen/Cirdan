package Cirdan::View::MT;
use Any::Moose;
use Text::MicroTemplate qw(build_mt);
use Text::MicroTemplate::File;
use Encode;

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

    if (ref $template eq 'GLOB' || ref \$template eq 'GLOB') {
        my $renderer = $RENDERER_CACHE{0 + *{$template}{IO}}
            ||= build_mt(do { local $/; scalar <$template> });
        return encode utf8 => $renderer->(@args)->as_string;
    } else {
        return encode utf8 => $self->mtf->render_file($template, @args)->as_string;
    }
}

1;
