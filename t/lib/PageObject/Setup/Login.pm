package PageObject::Setup::Login;

use strict;
use warnings;

use Carp;
use PageObject;

use PageObject::Setup::Admin;
use PageObject::Setup::CreateConfirm;
use Selenium::Remote::WDKeys;

use Moose;
extends 'PageObject';



sub url { return '/setup.pl'; }

sub verify {
    my ($self) = @_;
    my $driver = $self->driver;

    $driver->find_element_by_label($_)
        for ("Super-user login", "Password", "Database");
    return $self;
};


sub login {
    my ($self, $user, $password, $company) = @_;
    $self->driver->find_element_by_label("Super-user login")->click;
    do {
        my $element = $self->driver->find_element_by_label($_->{label});
        $element->click;
        $element->send_keys($_->{value});
        $element->send_keys(KEYS->{'tab'}) if defined $_->{list};
    } for ({ label => "Super-user login",
             value => $user,
             list => 1 },
           { label => "Password",
             value => $password },
           { label => "Database",
             value => $company });
    $self->driver->find_button("Login")->click;
    return $self->driver->page(PageObject::Setup::Admin->new(%$self));
}

sub login_non_existent {
    my $self = shift @_;

    $self->login(@_);
    return $self->driver->page(PageObject::Setup::CreateConfirm->new(%$self));
}


__PACKAGE__->meta->make_immutable;

1;
