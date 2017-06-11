package Mojolicious::Command::pump::add; 
use Mojo::Base 'Mojolicious::Command';

has description => 'NAMES add file(s) to your light app.';
has usage => sub { shift->extract_usage };

use Mojo::File 'path';
use MIME::Base64 qw(decode_base64 encode_base64);

use Mojo::Util 'getopt';

sub run {
    my $source = pop;
    my ($command, @args) = @_;

    my ($base64_them, $inplace, $no_auto_base64);
    getopt \@args,
        'i|inplace' => sub { $inplace++ },
        't|text' => sub { $no_auto_base64 ++ },
        'b|binary' => sub { $base64_them ++ },
        ;

    my $type = $base64_them ? 'base64' : '';
    my @files = @args;

    return unless @files;
    
    for my $path (@files) { 
        my $file = path($path);
        my $bn = $file->basename;
        my $base64_this = $base64_them;

        # if you don't set -b, but it's not text, base64 it.
        # if file is missing, it's gross but OK to base64 everything 
        $base64_this = (`file $path`) !~ /text/ ?  'base64' : ''
            if not $no_auto_base64 and not $base64_them;

        my $content = $file->slurp;

        die "$path contains lines starting with '\@\@'.\n"
          . "   adding this file as-is will result in it appearing as multiple "
          . "embedded files in your app.\n"
          . "   You can still add this file by either:\n"
          . "     - specifying -b to base64 encode the content.\n"
          . "     - adding something before the '\@\@', like so: <% %>$1\n\n"
          . "Refusing to continue.\n"
          if $content =~ /^( \@\@ [^\n\r]+ )/smxg and not $base64_this;

        my %file = (
            name     => $path,

            encoding => $type,
            raw      => $base64_this
                      ? encode_base64( $content )
                      :  $content,

            headline => "@@ $bn" 
                . ($base64_this ?" ($type)\n" :"\n"),

        );

        printf "Adding %s %s\n",$path, $type if $inplace;

        $source->append( \%file );
    }
    $source->write_lite_app        if $inplace;
    print $source->to_lite_app unless $inplace;
    
}
1
