package QCMG::Visualise::QSigCompare;

##############################################################################
#
#  Module:   QCMG::Visualise:QSigCompare.pm
#  Author:   John V Pearson
#  Created:  2012-02-16
#
#  Read a qsignature XML file and create a HTML file that uses the
#  Google chart API to display appropriate graphs and summary tables.
#
#  $Id$
#
##############################################################################

use strict;
use warnings;

use Carp qw( carp croak confess );
use Data::Dumper;
use XML::LibXML;

use QCMG::Google::Charts;
use QCMG::HTML::TabbedPage;
use QCMG::HTML::Tab;
use QCMG::Util::QLog;
use QCMG::Util::XML qw( get_attr_by_name get_node_by_name );
use QCMG::Visualise::QSigBam;
use QCMG::Visualise::QSigResults;
use QCMG::Visualise::Util qw( parse_xml_table );


use vars qw( $SVNID $REVISION );

( $REVISION ) = '$Revision$ ' =~ /\$Revision:\s+([^\s]+)/;
( $SVNID ) = '$Id$'
    =~ /\$Id:\s+(.*)\s+/;


sub new {
    my $class  = shift;
    my %params = @_;

    croak "You must supply one of file/xmltext/xmlnode to new()"
        unless (exists $params{file} or
                exists $params{xmltext} or
                exists $params{xmlnode});

    my $self = { file      => '',
                 xmltext   => '',
                 xmlnode   => undef,
                 charts    => QCMG::Google::ChartCollection->new(),
                 page      => QCMG::HTML::TabbedPage->new(),
                 mode      => $params{mode} || 0,
                 greenmax  => $params{greenmax} || 0.025,
                 yellowmax => $params{yellowmax} || 0.04,
                 verbose   => $params{verbose} || 0 };
    bless $self, $class;

    # Enable Google charts API
    $self->page->use_google_charts(1);

    # Ultimately we need a XML::LibXML::Element but we could have been
    # passed an Element object, a filename or a text blob.  In the latter
    # two cases, we need to create an XML node from the file or text.

    if (exists $params{xmlnode}) {
        my $type = ref($params{xmlnode});
        croak 'xmlnode parameter must refer to a XML::LibXML::Element '.
              "object not [$type]" unless ($type eq 'XML::LibXML::Element');
        my $name = $params{xmlnode}->nodeName;
        croak "xmlnode parameter must be a QSigCompare Element not [$name]"
            unless ($name eq 'QSigCompare');
        $self->{xmlnode} = $params{xmlnode};
    }
    elsif (exists $params{xmltext}) {
        my $xmlnode = undef;
        eval{ $xmlnode = XML::LibXML->load_xml( string => $params{xmltext} ); };
        croak $@ if $@;
        $self->{xmlnode} = $xmlnode;
    }
    elsif (exists $params{file}) {
        my $xmlnode = undef;
        eval{ $xmlnode = XML::LibXML->load_xml( location => $params{file} ); };
        croak $@ if $@;
        $self->{xmlnode} = $xmlnode;
    }
    else {
        confess "Uh oh - should not be able to get here!"
    }

    return $self;
}


sub file {
    my $self = shift;
    return $self->{file};
}


sub charts {
    my $self = shift;
    return $self->{charts};
}


sub page {
    my $self = shift;
    return $self->{page};
}


sub xmlnode {
    my $self = shift;
    return $self->{xmlnode};
}


sub greenmax {
    my $self = shift;
    return $self->{greenmax};
}


sub yellowmax {
    my $self = shift;
    return $self->{yellowmax};
}


sub verbose {
    my $self = shift;
    return $self->{verbose};
}


sub html {
    my $self = shift;
    return $self->page->as_html;
}   
 
 
sub process {
    my $self = shift;
    my $mode = shift || 0;

    my $file   = $self->file;
    my $charts = $self->charts;  # QCMG::Google::ChartCollection object
    my $page   = $self->page;    # QCMG::HTML::TabbedPage object
    my $root   = $self->xmlnode;

    # Pull out info for header
    my $creation_date = get_attr_by_name( $root, 'creation_date' );
    my $created_by = get_attr_by_name( $root, 'created_by' );
    my $code_version = get_attr_by_name( $root, 'code_version' );
    $page->add_content( 
                 '<p class="header">' .
                 "<i>Generated on: </i><b>$creation_date</b>" .
                 ' &nbsp;&nbsp;&nbsp; '.
                 "<i>Generated by: </i><b>$created_by</b>" .
                 ' &nbsp;&nbsp;&nbsp; '.
                 "<i>Generated using software: </i><b>v$code_version</b>");

    # Extract all of the reportable units
    my @bams    = $root->findnodes( "BAMFiles" );
    my @results = $root->findnodes( "Results" );

    # Start parsing all of the reports into Google::Charts

    foreach my $result (@results) {
        my $obj = QCMG::Visualise::QSigResults->new(
                        xmlnode   => $result,
                        charts    => $charts,
                        mode      => $mode,
                        greenmax  => $self->greenmax,
                        yellowmax => $self->yellowmax,
                        verbose   => $self->verbose );
        $obj->process;
        $page->add_subtab( $obj->tab );
    }

    foreach my $bam (@bams) {
        my $obj = QCMG::Visualise::QSigBam->new(
                        xmlnode => $bam,
                        charts  => $charts,
                        verbose => $self->verbose );
        $obj->process;
        $page->add_subtab( $obj->tab );
    }

    # If we've parsed all of the reports then all our charts should be
    # ready so we can add the javascript
    $page->add_content( $charts->javascript );
}


1;

__END__


=head1 NAME

QCMG::Visualise::QSigCompare - Perl module for creating HTML pages
from qsignature XML reports


=head1 SYNOPSIS

 use QCMG::Visualise::QSigCompare;

 my $report = QCMG::Visualise::QSigCompare->new( file => 'report.xml' );
 print $report->as_html( 'report.html' );


=head1 DESCRIPTION


=head1 PUBLIC METHODS

=over

=item B<new()>

=item B<file()>

=item B<as_html()>

=item B<verbose()>

=back 


=head1 AUTHOR

=over 2

=item John Pearson, L<mailto:j.pearson@uq.edu.au>

=back


=head1 VERSION

$Id$


=head1 COPYRIGHT

Copyright (c) The University of Queensland 2012

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
