use strict;
use warnings;
package Mojolicious::Command::pump::Core;

#ABSTRACT: Parse up a Mojo::Lite app 

use Mojo::Base -base;
use Mojo::File 'path';

my $NOISY_PARSE = 0;

# this is the Mojo::Lite app.
has app => sub { die "We need the app." };

# the lite app
has app_path => undef; # undef seems like an ok default
# All the @@ thing sections.
has embedded_files  => sub { $_[0]->_parsed->{embedded_files}; };
# Everything before __DATA__
has app_code        => sub { $_[0]->_parsed->{code}            };
# 
has raw_file        => sub { $_[0]->_parsed->{raw};            };

has _parsed         => undef;


# Parse the lite app
sub from_lite_app { my ($package, $path, $app) = @_;

    $path = path($path) unless ref $path;

    my $fh = $path->open('<');
    die "Oh no!" unless $fh;

    my $core = $package->new(
        app_path=>$path,
        app => $app,
    );
    $core->_parsed( $core->_parse( $fh ) );

    return $core 
}

#
sub to_lite_app { my $source = shift;
    
    return join "",
        $source->app_code,
        "__DATA__\n",
        map {
            #sprintf "[[%s]]",
            join "",
                $_->{headline} // '',
                $_->{raw},
        }
        @{ $source->embedded_files }

}
sub write_lite_app { my $source = shift;
    path($source->app_path)->spurt( $source->to_lite_app )
}

sub append { my ($source, $file_record) = @_;
    push @{ $source->embedded_files }, $file_record
}

sub _parse { my ($self, $fh ) = @_;

    my $parsed = { raw  => '', code => '',
        embedded_files  => [{
               name     => '',     # name.html.ep
               encoding => '',     # (encoding)
               raw      => '', }], # text
    };
        
    my ($data_line, $line); # line numbers

    # https://metacpan.org/pod/PPI::Statement::Data
    # ... might mean less of this regex-nonsense.
    while ( <$fh> ) { $line++;
        chomp (my $trimmed=$_);

        $self->app->log->debug(sprintf
         # === file read ===           == line  ==
         # overall, __DATA__           length text
         #   |    |      === ef ===    |     |
         #   |    |      name length   |     |
         #   |    |       |   |        |     |
         "#[%3uf, %3uD] [%s %3u bytes] %3ul - %s",

        $line, $data_line // 0,

        (eval{        $parsed->{embedded_files}[-1]{name} } // ''),
        (eval{ length $parsed->{embedded_files}[-1]{raw}  } // 0 ),

        (length $_)//0,
        $trimmed,
        ) if $NOISY_PARSE;

        $data_line++
            if defined $data_line;

        $data_line = 0, next
            if not defined $data_line
            and /^__DATA__$/;
    
        push @{ $parsed->{embedded_files} },
            { name => $1, encoding => $2, headline => $_ }
            and next # don't include the header in {raw}
            if $data_line
            and /^\@\@ [ ] ([^ \n]+) (?: [ ] [(] [^)]+ [)] )? /smxg;

        next # between DATA and @@, drop it 
            if $data_line
            and not @{ $parsed->{embedded_files} || [] }
            ;
        
        my $line=$_;
        $$_ .= $line for 
            \$parsed->{raw},
            $data_line
                ? \( $parsed->{embedded_files}[-1]{raw} )
                : \( $parsed->{code} );

        
    }

    return $parsed
};


1
