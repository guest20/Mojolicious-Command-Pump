use strict;
use warnings;
package Mojolicious::Command::pump;

use Mojo::Base 'Mojolicious::Commands';

has description => 'Inflate/Deflate templates and static content';
has hint        => <<EOF;

You definitely want to have your application versioned before running any of these commands.
EOF
has message    => sub { shift->extract_usage . "\nCommands:\n" };
has namespaces => sub { ['Mojolicious::Command::pump'] };

use Mojolicious::Command::pump::Core;
use Mojo::File 'path';
use Mojo::Util 'getopt';

sub run  {
    my ($command, @args) = @_;

    my $src = path($ENV{MOJO_EXE})->to_abs;
    my $source = Mojolicious::Command::pump::Core->from_lite_app(
        $src, $command->app,
    );

    $command->SUPER::run(@args, $source);
    
};
sub help { shift->run(@_) }

1

__DATA__

=encoding utf8
 
=head1 NAME
 
Mojolicious::Command::pump - Inflate/Deflate templates and static content.
 
=head1 SYNOPSIS
 
Usage: APPLICATION pump subcommand [OPTIONS]

    $ ./bin/demo pump list
    >> 402528 bytes of perl <<
    @@ (preamble)                                              58 bytes
    @@ index.html.ep                                           195 bytes
    @@ layouts/default.html.ep                                 104 bytes

    $ ./bin/demo pump add -i -b  cute-kitten.jpg
    Adding cute-kitten.jpg base64

    $ ./bin/demo pump list |grep kitten
    @@ cute-kitten.jpg                                         123071 bytes
 
    $ ./bin/demo pump rm -i cute-kitten.jpg
    cute-kitten.jpg, matches: cute-kitten.jpg so I removed it.

C<add> and C<rm> both take C<-i> which does an inplace edit of your app (the default is to print out the changed app)

C<add> takes both C<-b> and C<-t>.
=over 4


=item * With C<-b> files are always base64 encoded,

=item * Without C<-b> files are based64'ed when C<`file`> says they're not text.

=item * You can disable the C<`file`> check with C<-t>, meaning everything is Text. (so nothing should be base64'ed)

=back

=head1 DESCRIPTION
 
L<Mojolicious::Command::pump> list pump subcommands

Manage the embeded files in your lite_app.
 
=head1 ATTRIBUTES
 
L<Mojolicious::Command::pump> inherits all attributes from
L<Mojolicious::Commands> and implements the following new ones.
 
=head2 description
 
  my $description = $pump->description;
  $pump      = $pump->description('Foo');
 
Short description of this command, used for the command list.
 
=head2 hint
 
  my $hint   = $pump->hint;
  $pump = $pump->hint('Foo');
 
Short hint shown after listing available generator commands.
 
=head2 message
 
  my $msg    = $pump->message;
  $pump = $pump->message('Bar');
 
Short usage message shown before listing available generator commands.
 
=head2 namespaces
 
  my $namespaces = $pump->namespaces;
  $pump     = $pump->namespaces(['MyApp::Command::pump']);
 
Namespaces to search for available generator commands, defaults to
L<Mojolicious::Command::pump>.
 
=head1 METHODS
 
L<Mojolicious::Command::pump> inherits all methods from
L<Mojolicious::Commands> and implements the following new ones.
 
=head2 help
 
  $pump->help('app');
 
Print usage information for command.
 
=head1 SEE ALSO
 
L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicious.org>.
 
=cut
