# -*- perl -*

package Xen::Tools::Common;

=head1 NAME

Xen::Tools::Common - Common funtions used in xen-tools' Perl scripts

=head1 SYNOPSIS

 use Xen::Tools::Common;

=cut

use warnings;
use strict;

use Exporter 'import';
use vars qw(@EXPORT_OK @EXPORT);

@EXPORT = qw(readConfigurationFile);

=head1 FUNCTIONS

=head2 readConfigurationFile

=begin doc

  Read the specified configuration file, and update our global configuration
 hash with the values found in it.

=end doc

=cut

sub readConfigurationFile
{
    my ($file, $CONFIG) = (@_);

    # Don't read the file if it doesn't exist.
    return if ( !-e $file );


    my $line = "";

    open( FILE, "<", $file ) or die "Cannot read file '$file' - $!";

    while ( defined( $line = <FILE> ) )
    {
        chomp $line;
        if ( $line =~ s/\\$// )
        {
            $line .= <FILE>;
            redo unless eof(FILE);
        }

        # Skip lines beginning with comments
        next if ( $line =~ /^([ \t]*)\#/ );

        # Skip blank lines
        next if ( length($line) < 1 );

        # Strip trailing comments.
        if ( $line =~ /(.*)\#(.*)/ )
        {
            $line = $1;
        }

        # Find variable settings
        if ( $line =~ /([^=]+)=([^\n]+)/ )
        {
            my $key = $1;
            my $val = $2;

            # Strip leading and trailing whitespace.
            $key =~ s/^\s+//;
            $key =~ s/\s+$//;
            $val =~ s/^\s+//;
            $val =~ s/\s+$//;

            # command expansion?
            if ( $val =~ /(.*)`([^`]+)`(.*)/ )
            {

                # store
                my $pre  = $1;
                my $cmd  = $2;
                my $post = $3;

                # get output
                my $output = `$cmd`;
                chomp($output);

                # build up replacement.
                $val = $pre . $output . $post;
            }

            # Store value.
            $CONFIG->{ $key } = $val;
        }
    }

    close(FILE);
}

=head1 AUTHORS

 Steve Kemp, http://www.steve.org.uk/
 Axel Beckert, http://noone.org/abe/
 Dmitry Nedospasov, http://nedos.net/
 St�phane Jourdois

 Merged from several scripts by Axel Beckert.

=cut