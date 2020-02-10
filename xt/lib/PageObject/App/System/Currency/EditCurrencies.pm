package PageObject::App::System::Currency::EditCurrencies;

use strict;
use warnings;

use Carp;
use PageObject;

use Moose;
use namespace::autoclean;
extends 'PageObject';
with 'PageObject::App::Roles::Dynatable';

__PACKAGE__->self_register(
    'system-currency',
    './/div[@id="system-currency"]',
    tag_name => 'div',
    attributes => {
        id => 'system-currency',
    }
);


sub _verify {
    my ($self) = @_;
    return $self;
}

__PACKAGE__->meta->make_immutable;

1;
