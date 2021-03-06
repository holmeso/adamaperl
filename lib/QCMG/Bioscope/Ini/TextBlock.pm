package QCMG::Bioscope::Ini::TextBlock;

###########################################################################
#
#  Module:   QCMG::Bioscope::Ini::TextBlock.pm
#  Creator:  John V Pearson
#  Created:  2010-09-26
#
#  A text string for inclusion in a Bioscope INI file.
#
#  $Id$
#
###########################################################################

use strict;
use warnings;

use IO::File;
use IO::Zlib;
use Data::Dumper;
use Carp qw( croak );
use vars qw( $VERSION @ISA );

( $VERSION ) = '$Revision$ ' =~ /\$Revision:\s+([^\s]+)/;


###########################################################################
#                          PUBLIC METHODS                                 #
###########################################################################


sub new {
    my $class  = shift;
    my %params = @_;

    croak 'name parameter is compulsory' unless
       (exists $params{name} and defined $params{name} and $params{name}); 
    croak 'value parameter is compulsory' unless
       (exists $params{name} and defined $params{name} and $params{name}); 

    my $self = { name       => $params{name},
                 value      => $params{value},
                 lines_pre  => ($params{lines_pre} ? $params{lines_pre} : 0),
                 lines_post => ($params{lines_post} ? $params{lines_post} : 0),
                 version    => $VERSION };

    bless $self, $class;
}


sub name {
    my $self = shift;
    return $self->{name} = shift if @_;
    return $self->{name};
}

sub value {
    my $self = shift;
    return $self->{value} = shift if @_;
    return $self->{value};
}

sub lines_pre {
    my $self = shift;
    return $self->{lines_pre} = shift if @_;
    return $self->{lines_pre};
}

sub lines_post {
    my $self = shift;
    return $self->{lines_post} = shift if @_;
    return $self->{lines_post};
}

sub version {
    my $self = shift;
    return $self->{version};
}

sub name_length {
    my $self = shift;
    return 0;  # All constituent objects must implement this method
}   


sub as_text {
    my $self   = shift;

    my $text = '';
    $text .= "\n" x $self->lines_pre;
    $text .= $self->value;
    $text .= "\n" x $self->lines_post;

    return $text;
}


1;
__END__


=head1 NAME

QCMG::Bioscope::Ini::TextBlock - A Bioscope INI file text block


=head1 SYNOPSIS

 use QCMG::Bioscope::Ini::TextBlock;
 my $t = QCMG::Bioscope::Ini::TextBlock->new(
             name       => 'A.header',
             lines_pre  => 0,
             lines_post => 0 );
  
 my $header = << '_EO_HEADER_';
 ##########################################################################
 #
 #  File:          ~BS_I_FILENAME~
 #  Generated on:  ~BS_I_TODAY~
 #  Generated by:  v~BS_I_VERSION~
 #
 ##########################################################################
 _EO_HEADER_

 $t->value( $header );
 print $t->as_text;


=head1 DESCRIPTION

This module represents a block of text for incorporation into a Bioscope
INI file.  In general this module will not be used directly but rather a
A TextBlock requires at least a name and value to be supplied by the user.
These values would usually be specified in the call to B<new()> although
there are get/set accessors.


=head1 PUBLIC METHODS

=over

=item B<new()>

Takes name, value and comment input parameters of which only comment is
optional.

=item B<name()>

 $t->name( 'file.header' );
 print $t->name;

Get/set the TextBlock name.

=item B<value()>

 $t->value( "\n\nFile Header\n\n" );
 print $t->value;

Get/set the TextBlock value.

=item B<lines_pre()>

 $t->lines_pre( 2 );
 print $t->lines_pre;

Get/set the number of blank lines to be output before this TextBlock in
B<as_text()>.

=item B<lines_post()>

 $t->lines_post( 2 );
 print $t->lines_post;

Get/set the number of blank lines to be output after this TextBlock in
B<as_text()>.

=item B<version()>

 print $p->version;

Get the version of the QCMG::Bioscope::Ini::TextBlock module.

=item B<name_length()>

 print $t->name_length;

This method has no useful function for thsi class but all objects that
can be incorporated into ParameterCollection objects must implement it
so for this class, it always returns 0.

=item B<as_text()>

 print $t->as_text;

This method returns the contents of TextBlock as a string.  The string
includes any blank lines specified by B<lines_pre()> and
B<lines_post()> as well as B<value()>.

=back


=head1 SEE ALSO

=over

=item QCMG::Bioscope::Ini::IniFile

=back


=head1 AUTHORS

=over

=item John Pearson L<mailto:j.pearson@uq.edu.au>

=back


=head1 VERSION

$Id$


=head1 COPYRIGHT

Copyright (c) The University of Queensland 2009-2014

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
