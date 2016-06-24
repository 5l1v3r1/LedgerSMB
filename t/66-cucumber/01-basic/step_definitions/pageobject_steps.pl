#!perl


use lib 't/lib';
use strict;
use warnings;


use Test::More;
use Test::BDD::Cucumber::StepFile;



###############
#
# Setup steps
#
###############


When qr/I confirm database creation with these parameters:/, sub {
    my $data = C->data;
    my %data;

    $data{$_->{'parameter name'}} = $_->{value} for @$data;
    S->{page}->create_database(%data);
};

When qr/I log into ("(.*)"|(.*)) using the super-user credentials/, sub {
    my $company = $2 || S->{$3};

    if (S->{"nonexistent company"}) {
        S->{page}->login_non_existent(
            $ENV{PGUSER}, $ENV{PGPASSWORD}, $company);
    }
    else {
        S->{page}->login($ENV{PGUSER}, $ENV{PGPASSWORD}, $company);
    }
};

When qr/I create a user with these values:/, sub {
    my $data = C->data;
    my %data;

    $data{$_->{'label'}} = $_->{value} for @$data;
    S->{page}->create_user(%data);
};

When qr/I request the users list/, sub {
    S->{page}->list_users;
};

When qr/I request to add a user/, sub {
    S->{page}->add_user;
};

Then qr/I should see the table of available users:/, sub {
    my @data = map { $_->{'Username'} } @{ C->data };
    my $users = S->{page}->get_users_list;

    is_deeply($users, \@data, "Users on page correspond with expectation");
};

When qr/I copy the company to "(.*)"/, sub {
    my $target = $1;

    S->{page}->copy_company($target);
};

When qr/I request the user overview for "(.*)"/, sub {
    my $user = $1;

    S->{page}->edit_user($user);
};


Then qr/I should see all permission checkboxes checked/, sub {
    my $page = S->{page};
    my $checkboxes = $page->get_perms_checkboxes(filter => 'all');
    my $checked_boxes = $page->get_perms_checkboxes(filter => 'checked');

    ok(scalar(@{ $checkboxes }) > 0,
       "there are checkboxes");
    ok(scalar(@{ $checkboxes }) == scalar(@{ $checked_boxes }),
       "all perms checkboxes checked");
};


Then qr/I should see no permission checkboxes checked/, sub {
    my $page = S->{page};
    my $checked_boxes = $page->get_perms_checkboxes(filter => 'checked');

    ok(0 == scalar(@{ $checked_boxes }),
       "no perms checkboxes checked");
};


Then qr/I should see only these permission checkboxes checked:/, sub {
    my $page = S->{page};
    my @data = map { $_->{"perms label"} } @{ C->data };
    my $checked_boxes = $page->get_perms_checkboxes(filter => 'checked');

    is(scalar(@{ $checked_boxes }), scalar(@data),
       "Expected number of perms checkboxes checked");
    ok($page->is_checked_perms_checkbox($_),
       "Expect perms checkbox with label '$_' to be checked")
        for (@data);
};



1;
