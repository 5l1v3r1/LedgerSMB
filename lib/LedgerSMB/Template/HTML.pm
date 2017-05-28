
=head1 NAME

LedgerSMB::Template::HTML - Template support module for LedgerSMB

=head1 METHODS

=over

=item process ($parent, $cleanvars)

Processes the template for HTML.

=item postprocess ($parent)

Currently does nothing.

=item escape($string)

Escapes a scalar string and returns the sanitized version.

=back

=head1 Copyright (C) 2007, The LedgerSMB core team.

This work contains copyrighted information from a number of sources all used
with permission.

It is released under the GNU General Public License Version 2 or, at your
option, any later version.  See COPYRIGHT file for details.  For a full list
including contact information of contributors, maintainers, and copyright
holders, see the CONTRIBUTORS file.
=cut

package LedgerSMB::Template::HTML;

use strict;
use warnings;

use Template;
use Template::Parser;
use LedgerSMB::Template::TTI18N;
use HTML::Entities;
use HTML::Escape;
use LedgerSMB::Sysconfig;
use LedgerSMB::Company_Config;
use LedgerSMB::App_State;

my $binmode = ':utf8';
my $extension = 'html';

sub escape {
    my $vars = shift @_;
    return undef unless defined $vars;
    #$vars = encode_entities($vars);
    $vars = escape_html($vars);
    return $vars;
}

sub process {
    my ($parent, $cleanvars, $output) = @_;

    my $dojo_theme;
    $dojo_theme = $LedgerSMB::App_State::Company_Config->{dojo_theme}
            if $LedgerSMB::App_State::Company_Config;
    $cleanvars->{dojo_theme} //= $dojo_theme;
    $cleanvars->{dojo_theme} //= $LedgerSMB::Sysconfig::dojo_theme;;
    $cleanvars->{dojo_built} ||= $LedgerSMB::Sysconfig::dojo_built;
    $cleanvars->{UNESCAPE} = sub { return decode_entities(shift @_) };

    my $arghash = $parent->get_template_args($extension,$binmode);
    my $template = Template->new($arghash) || die Template->error();
    unless ($template->process(
                $parent->get_template_source($extension),
                {
                    %$cleanvars,
                    %$LedgerSMB::Template::TTI18N::ttfuncs,
                },
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
