package Mojolicious::Command::pump::list; 
use Mojo::Base 'Mojolicious::Command';

has description => "What's even in this app?";
has usage => sub { shift->extract_usage };

sub run {
    my $source = pop;
    my ($command) = @_;

    printf ">> %s bytes of perl <<\n",
                length $source->raw_file;

    for (@{ $source->embedded_files }) {
        printf "@@ %-55s %s bytes\n",
                $_->{name} || '(preamble)',
                length $_->{raw}
    }


}

1

