
=head1 NAME

LedgerSMB::Template::CSV - Template support module for LedgerSMB

=head1 METHODS

=over

=item process ($parent, $cleanvars)

Processes the template for text.

=item postprocess ($parent)

Returns the output filename.

=item escape ($var)

Implements the templates escaping protocol. Returns C<$var>.

=back

=head1 Copyright (C) 2007, The LedgerSMB core team.

This work contains copyrighted information from a number of sources all used
with permission.

It is released under the GNU General Public License Version 2 or, at your
option, any later version.  See COPYRIGHT file for details.  For a full list
including contact information of contributors, maintainers, and copyright
holders, see the CONTRIBUTORS file.
=cut

package LedgerSMB::Template::CSV;

use warnings;
use strict;

use Template;

my $binmode = ':utf8';
my $extension = 'csv';

sub escape {
    return shift;
}

sub process {
    my ($parent, $cleanvars, $output) = @_;

    my $arghash = $parent->get_template_args($extension,$binmode);
    my $template = Template->new($arghash) || die Template->error();
    unless ($template->process(
                $parent->get_template_source($extension),
                $cleanvars,
                $output,
                {binmode => $binmode})
    ){
        my $err = $template->error();
        die "Template error: $err" if $err;
    }
    return;
}

sub postprocess {
    my $parent = shift;
    $parent->{mimetype} = 'text/' . $extension;
    return;
}

1;
