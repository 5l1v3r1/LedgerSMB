=head1 NAME

LedgerSMB::PGOld - Old DBObject replacement for 1.3-era LedgerSMB code

=head1 SYNPOSIS

This is like DBObject but uses the PGObject::Simple for base functionality.

=head1 METHODS

See PGObject::Simple

=cut

# This is temporary until we can get rid of it.  Basically the following
# namespaces need to be moved to Moose:
#
# LedgerSMB::Setting
# LedgerSMB::DBObject
# Then we can delete this module.

package LedgerSMB::PGOld;
use base 'PGObject::Simple';
use LedgerSMB::App_State;

sub new {
    my ($pkg, $args) = @_;
    my $mergelist = $args->{mergelist} || [keys %{$args->{base}}];
    my $self = { map { $_ => $args->{base}->{$_} } @$mergelist };
    $self =  PGObject::Simple::new($pkg, %$self);
    return $self;
}

sub set_dbh {
    my ($self) = @_;
    $self->{_DBH} =  LedgerSMB::App_State::DBH();
    return  LedgerSMB::App_State::DBH();
}

1; 
