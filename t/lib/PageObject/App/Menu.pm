package PageObject::App::Menu;

use strict;
use warnings;

use Carp;
use PageObject;
use MIME::Base64;

use Module::Runtime qw(use_module);

use Moose;
extends 'PageObject';


my %menu_path_pageobject_map = (
    "Contacts > Add Contact" => '',
    "Contacts > Search" => 'PageObject::App::Search::Contact',
    "AR > Search" => 'PageObject::App::Search::AR',
    "AP > Search" => 'PageObject::App::Search::AP',
    "Budgets > Search" => 'PageObject::App::Search::Budget',
    "HR > Employees > Search" => 'PageObject::App::Search::Employee',
    "Order Entry > Reports > Sales Orders" => '',
    "Order Entry > Reports > Purchase Orders" => '',
    "Order Entry > Generate > Sales Orders" => '',
    "Order Entry > Generate > Purchase Orders" => '',
    "Order Entry > Combine > Sales Orders" => '',
    "Order Entry > Combine > Purchase Orders" => '',
    );


sub verify {
    my ($self) = @_;
    my $driver = $self->driver;

    my @logged_in_found =
        $driver->find_elements_containing_text("Logged in as");
    my @logged_into_found =
        $driver->find_elements_containing_text("Logged into");

    return $self
        unless ((scalar(@logged_in_found) > 0)
                && scalar(@logged_into_found) > 0);
};


sub click_menu {
    my ($self, $path) = @_;
    my $root = $self->driver->find_element("//*[\@id='top_menu']");
    my $driver = $self->driver;

    my $item = $root;
    my $ul = '';

    do {
        $item = $driver->find_child_element($item,".$ul/li[./a[text()='$_']]");
        my $link = $driver->find_child_element($item,"./a");
        $driver->execute_script("arguments[0].scrollIntoView()", $link);
        $link->click
            unless ($item->get_attribute('class') =~ /\bmenu_open\b/);

        $ul = '/ul';
    } for @$path;

    my $tgt_class = $menu_path_pageobject_map{join(' > ', @$path)};
    use_module($tgt_class);
    return $driver->page->maindiv->content($tgt_class->new(%$self));
}


__PACKAGE__->meta->make_immutable;

1;
