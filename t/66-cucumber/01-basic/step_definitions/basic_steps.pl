#!perl


use lib 't/lib';
use strict;
use warnings;


use Test::More;
use Test::BDD::Cucumber::StepFile;

use Selenium::Remote::Driver;
use Selenium::Support qw( find_element_by_label
 find_button find_dropdown find_option
 try_wait_for_page
 prepare_driver element_has_class element_is_dropdown);

use MIME::Base64;

sub get_driver {
    my ($stash) = @_;

    return $stash->{feature}->{driver};
}




Given qr/a LedgerSMB instance/, sub {

    return if defined S->{feature}->{driver};

    my $driver = new Selenium::Remote::Driver(
        'port' => 4422,
        ) or die "Can't set up Selenium connection";
    $driver->set_implicit_wait_timeout(3000);
    &prepare_driver($driver);
    S->{feature}->{driver} = $driver;
};

Given qr/a user named "(.*)" with a password "(.*)"/, sub {
    S->{feature}->{user} = $1;
    S->{feature}->{passwd} = $2;
};

Given qr/a database super-user/, sub {
    S->{feature}->{"the super-user name"} = 'postgres';
    S->{feature}->{"the super-user password"} = 'a';
};

Given qr/a non-existant company name/, sub {
    #TODO: generate a company name and verify that it doesn't exist...
    S->{feature}->{"the company name"} = "non-existant";
};

When qr/I navigate to '(.*)'/, sub {
    my $url = $ENV{LSMB_BASE_URL} . $1;

    &get_driver(S)->get($url);
    &try_wait_for_page(&get_driver(S));
};

When qr/I enter (([^"].*)|"(.*)") into "(.*)"/, sub {
    my $param = $2;
    my $value = $3;
    my $label = $4;

    my $element = &find_element_by_label(&get_driver(S), $label);
    ok($element, "found element with label '$label'");
    $value ||= S->{feature}->{$param};
    $element->send_keys($value);
};

When qr/I enter these values:/, sub {
    my $driver = get_driver(S);
    foreach my $field (@{ C->data }) {
        my $elm = find_element_by_label($driver, $field->{label});
        if (element_is_dropdown($elm)) {
            find_option($driver, $field->{value}, $field->{label})->click;
        }
        else {
            $elm->send_keys($field->{value});
        }
    }
};

When qr/I select "(.*)" from the drop down "(.*)"/, sub {
    my $value = $1;
    my $label = $2;

    find_option(get_driver(S), $value, $label)->click;
};


When qr/I press "(.*)"/, sub {
    my $button_text = $1;

    find_button(get_driver(S), $button_text)->click;
    &try_wait_for_page(&get_driver(S));
};


Then qr/I should see a (radio button|textbox|password box) "(.*)"/, sub {
    my $want_type = $1;
    my $label = $2;
    my $element = &find_element_by_label(&get_driver(S), $label);

    my %element_type = (
        'radio button' => 'radio',
        'textbox'      => qr/(text)?/, # text or empty string
        'password box' => 'password',
        );

    is($element->get_tag_name, 'input', "$want_type tag name is 'input'");
    my $type = $element->get_attribute('type') || '';
    ok($type =~ m/^$element_type{$want_type}$/,
       "$want_type tag type att matches $element_type{$want_type}");
};

Then qr/I should see a (dropdown|combobox) "(.*)"/, sub {
    my $want_type = $1;
    my $label = $2;
    my $element = &find_element_by_label(&get_driver(S), $label);

    my %expect_tag_name = (
        'dropdown'    => 'select',
        'combobox'    => 'input',
        );

    is($element->get_tag_name, $expect_tag_name{$want_type},
       "$want_type tag name is '$expect_tag_name{$want_type}'");
};


Then qr/I should see "(.*)"/, sub {
    my $want_text = $1;

    my $element =
        &get_driver(S)->find_elements(
        "//*[contains(.,'$want_text')]
            [not(.//*[contains(.,'$want_text')])]");
};

Then qr/I should see a button "(.*)"/, sub {
    my $button_text = $1;

    my $btn = &get_driver(S)->find_element(
        "//span[text()='$button_text'
                and contains(concat(' ',normalize-space(\@class),' '),
                             ' dijitButtonText ')]
         | //button[text()='$button_text']
         | //input[\@value='$button_text'
                   and (\@type='submit' or \@type='image' or \@type='reset')]");

};


Then qr/I should see a drop down "(.*)"( with these items:)?/, sub {
    my $label_text = $1;
    my $want_values = $2;

    if ($want_values) {
        my $driver = get_driver(S);
        foreach my $option (@{ C->data }) {
            find_option($driver, $option->{text}, $label_text);
        }
    }
    else {
        find_dropdown(get_driver(S), $label_text);
    }
};


Then qr/I should see these fields:/, sub {
    my $driver = get_driver(S);
    foreach my $field (@{ C->data }) {
        find_element_by_label($driver, $field->{label});
    }
};
