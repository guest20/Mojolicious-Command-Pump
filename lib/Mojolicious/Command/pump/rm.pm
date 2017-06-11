mackage Mojolicious::Command::pump::rm; 
use Mojo::Base 'Mojolicious::Command';

has description => 'NAME drop `@@ NAME` from your light app.';
has usage => sub { shift->extract_usage };

use Mojo::Util 'getopt';
use Mojo::File 'path';
sub run {
    my $source = pop;
    my ($command, @args) = @_;

    my ($inplace);
    getopt \@args,
        'i|inplace' => sub { $inplace++ },
        ;
    my @names = @args;

    return unless @names;

    for my $name (@names) {

        my @matches;
        $source->embedded_files([
            grep {
                $_->{name} eq $name 
                    ? do { push @matches, $_->{name}; 0 }
                    : 1
            } @{ $source->embedded_files }
        ]);
        
        printf "%s, matches: %s so I removed it.\n",
            $name, join ', ', @matches
            if $inplace; 
    }
    $source->write_lite_app        if $inplace;
    print $source->to_lite_app unless $inplace;
}

1
