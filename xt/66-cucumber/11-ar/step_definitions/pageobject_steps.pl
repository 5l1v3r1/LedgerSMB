#!perl


use lib 'xt/lib';
use strict;
use warnings;

use LedgerSMB::App_State;
use LedgerSMB::Database;
use LedgerSMB::Entity::Person::Employee;
use LedgerSMB::Entity::User;
use LedgerSMB::PGDate;

use Module::Runtime qw(use_module);
use PageObject::App::Login;
use PageObject::App::AR::Invoice;

use Test::More;
use Test::BDD::Cucumber::StepFile;

Transform qr/^table:name,value/, sub {
    my ($c, $data) = @_;

    for my $row (@$data) {
        if (exists $row->{value} and $row->{value} eq '$$today') {
            $row->{value} = LedgerSMB::PGDate->today->to_output;
        }
    }
};

When qr/I open the sales invoice entry screen/, sub {
    my @path = split /[\n\s\t]*>[\n\s\t]*/, 'AR > Sales Invoice';

    S->{ext_wsl}->page->body->menu->click_menu(\@path);
    S->{ext_wsl}->page->body->verify;
};

When qr/I open the AR transaction entry screen/, sub {
    my @path = split /[\n\s\t]*>[\n\s\t]*/, 'AR > Sales Invoice';

    S->{ext_wsl}->page->body->menu->click_menu(\@path);
    S->{ext_wsl}->page->body->verify;
};

When qr/I select customer "(.*)"/, sub {
    my $customer = $1;

    my $page = S->{ext_wsl}->page->body->maindiv->content;
    $page->select_customer($customer);

};

When qr/I add an invoice line with (?:part|service) "(.+)"/, sub {
    my $part = $1;

    my $page = S->{ext_wsl}->page->body->maindiv->content;
    my @empty = $page->lines->empty_lines;
    my $empty = shift @empty;

    $empty->field_value('Number', $part);
    $page->update;
};

Then qr/I expect to see an invoice with (\d+) (empty )?lines?/, sub {
    my ($count, $empty) = ($1, $2);

    my $page = S->{ext_wsl}->page->body->maindiv->content;
    ###TODO: verify this is an invoice!

    my @lines = $empty ? $page->lines->empty_lines : $page->lines->all_lines;
    is(scalar(@lines), $count, 'Expected number of lines matches actual');
};

Then qr/I expect to see these invoice header fields and values/, sub {
    my $data = C->data;

    my $header = S->{ext_wsl}->page->body->maindiv->content->header;

    for my $exp_hdr (@$data) {
        my $val = $exp_hdr->{value};
        is($header->field_value($exp_hdr->{name}),
           $exp_hdr->{value},
           qq{Invoice header field $exp_hdr->{name} matches expected value});
    }
};

1;
