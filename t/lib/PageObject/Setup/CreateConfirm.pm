package PageObject::Setup::CreateConfirm;

use strict;
use warnings;

use Carp;
use Moose;
use PageObject;
extends 'PageObject';

use PageObject::Setup::CreateUser;


sub _verify {
    my ($self) = @_;
    my $page = $self->stash->{ext_wsl}->page;

    my @elements;
    push @elements, @{$page->find_all('*contains', text => $_)}
       for ("Database does not exist",
            "Create Database",
            "Database Management Console",
           );
    croak "Not on the company creation confirmation page " . scalar(@elements)
        if scalar(@elements) != 3;

    return $self;
};

sub create_database {
    my $self = shift @_;
    my %param = @_;
    my $page = $self->stash->{ext_wsl}->page;

    # Confirm database creation
    $page->find('*button', text => "Yes")->click;

    $page->find('*labeled', text => "Country Code")
        ->find_option($param{"Country code"})
        ->click;
    $page->find('*button', text => "Next")->click;

    $page->find('*labeled', text => "Chart of accounts")
        ->find_option($param{"Chart of accounts"})
        ->click;
    $page->find('*button', text => "Next")->click;

    # assert we're on the "Load Templates" page now
    $page->find('*contains', text => "Select Templates to Load");
    $page->find('*button', text => $_) for ("Load Templates");

    $page->find('*labeled', text => 'Templates')
        ->find_option($param{"Templates"})
        ->click;

    $page->find('*button', text => "Load Templates")->click;

    return $self->stash->{page} = PageObject::Setup::CreateUser->new(%$self);
}


__PACKAGE__->meta->make_immutable;

1;
