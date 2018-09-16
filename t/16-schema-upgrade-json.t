# Database schema upgrade pre-checks

use strict;
use warnings;

use Data::Dumper;
use DBI;
use Digest::MD5 qw( md5_hex );
use File::Temp qw( :seekable );
use IO::Scalar;
use MIME::Base64;
use Plack::Request;

use Log::Log4perl qw( :easy );
Log::Log4perl->easy_init($OFF);

use Test::More 'no_plan';
use Test::Exception;

use LedgerSMB;
use LedgerSMB::Database::ChangeChecks qw( run_checks load_checks );
use LedgerSMB::Upgrade::SchemaChecks::JSON qw( json_formatter_context );


my $dir = File::Temp->newdir();
my $json_dir = $dir->dirname;

sub _slurp {
    my ($fn) = @_;

    open my $fh, '<:encoding(UTF-8)', $fn;
    local $/ = undef;
    my $content = <$fh>;
    close $fh;

    return $content;
}

###############################################
#
#
#  Test helper routines
#
###############################################


# _check_hashid

is LedgerSMB::Upgrade::SchemaChecks::JSON::_check_hashid(
    { title => 'a title' }
    ),
    md5_hex( 'a title' ), '_check_hashid with only a title';
is LedgerSMB::Upgrade::SchemaChecks::JSON::_check_hashid(
    {
        title => 'a title',
        path => 'a path',
    } ),
    md5_hex( 'a path', 'a title' ), '_check_hashid with only a title';


my $tests;
my $dbh;
my $fh;
my @checks;
my $out;


###############################################
#
#
#  First test: Render the description && title
#
###############################################


$tests = <<HEREDOC;
package PreCheckTests;

use LedgerSMB::Database::ChangeChecks;

check 'first title',
    description => q|a description|,
    query => q|something|,
    on_submit => sub { return 1; },
    on_failure => sub {
        describe;
    };

1;
HEREDOC

$fh = IO::Scalar->new(\$tests);
lives_and(sub { @checks = load_checks($fh); is scalar @checks, 1 },
          'Loading a single check from file-handle');

$dbh = DBI->connect('DBI:Mock:', '', '');
$dbh->{mock_add_resultset} = {
    sql     => 'something',
    results => [
        [ 'headers' ],
        [ 'failing row' ],
        ],
};

is $LedgerSMB::Upgrade::SchemaChecks::JSON::cached_response, undef,
    'undef cached response';

$out = json_formatter_context {
    return ! run_checks($dbh, checks => \@checks);
} $json_dir;

is _slurp($out), q!{
   "failure" : {
      "description" : "a description",
      "title" : "first title"
   },
   "response" : {}
}
!, 'print a description on failure';


###############################################
#
#
#  Second test: Render a confirmation
#
###############################################

$tests = <<HEREDOC;
package PreCheckTests;

use LedgerSMB::Database::ChangeChecks;

check 'second title',
    description => q|a description|,
    query => q|something|,
    on_submit => sub { return 1; },
    on_failure => sub {
        confirm abc => 'Abc';
    };

1;
HEREDOC

$fh = IO::Scalar->new(\$tests);
lives_and(sub { @checks = load_checks($fh); is scalar @checks, 1 },
          'Loading a single check from file-handle');

$dbh = DBI->connect('DBI:Mock:', '', '');
$dbh->{mock_add_resultset} = {
    sql     => 'something',
    results => [
        [ 'headers' ],
        [ 'failing row' ],
        ],
};

$out = json_formatter_context {
    return ! run_checks($dbh, checks => \@checks);
} $json_dir;

is $LedgerSMB::Upgrade::SchemaChecks::JSON::cached_response, undef,
    'undef cached response';

is _slurp($out), q!{
   "failure" : {
      "confirmations" : [
         {
            "abc" : "Abc"
         }
      ]
   },
   "response" : {}
}
!, 'print the button/confirmation on failure';

###############################################
#
#
#  Third test: Render multiple confirmations
#
###############################################

$tests = <<HEREDOC;
package PreCheckTests;

use LedgerSMB::Database::ChangeChecks;

check 'third title',
    description => q|a description|,
    query => q|something|,
    on_submit => sub { return 1; },
    on_failure => sub {
        confirm abc => 'Abc', def => 'Def';
    };

1;
HEREDOC

$fh = IO::Scalar->new(\$tests);
lives_and(sub { @checks = load_checks($fh); is scalar @checks, 1 },
          'Loading a single check from file-handle');

$dbh = DBI->connect('DBI:Mock:', '', '');
$dbh->{mock_add_resultset} = {
    sql     => 'something',
    results => [
        [ 'headers' ],
        [ 'failing row' ],
        ],
};

$out = json_formatter_context {
    return ! run_checks($dbh, checks => \@checks);
} $json_dir;

is $LedgerSMB::Upgrade::SchemaChecks::JSON::cached_response, undef,
    'undef cached response';

is _slurp($out), q!{
   "failure" : {
      "confirmations" : [
         {
            "abc" : "Abc"
         },
         {
            "def" : "Def"
         }
      ]
   },
   "response" : {}
}
!, 'print the buttons/confirmations on failure';

###############################################
#
#
#  Fourth test: Render a grid (2-column p-key)
#
###############################################

$tests = <<HEREDOC;
package PreCheckTests;

use LedgerSMB::Database::ChangeChecks;

check 'fourth title',
    description => q|a description|,
    query => q|something|,
    tables => {
        'abc' => { prim_key => ['a', 'b'] },
    },
    on_submit => sub { return 1; },
    on_failure => sub {
        my (\$dbh, \$rows) = \@_;

        grid \$rows,
        name => 'grid',
        id => 'grid',
        table => 'abc',
        columns => [ 'a', 'b', 'c' ],
        edit_columns => ['c'];
    };

1;
HEREDOC

$fh = IO::Scalar->new(\$tests);
lives_and(sub { @checks = load_checks($fh); is scalar @checks, 1 },
          'Loading a single check from file-handle');

$dbh = DBI->connect('DBI:Mock:', '', '');
$dbh->{mock_add_resultset} = {
    sql     => 'something',
    results => [
        [ 'a', 'b', 'c' ],
        [ 'col1', 'col2', 'col3' ],
        ],
};

$out = json_formatter_context {
    return ! run_checks($dbh, checks => \@checks);
} $json_dir;


is _slurp($out), q!{
   "failure" : {
      "grids" : {
         "grid" : {
            "adjustment_fields" : [
               "c"
            ],
            "rows" : [
               {
                  "__pk" : "Y29sMQ== Y29sMg==",
                  "a" : "col1",
                  "b" : "col2",
                  "c" : "col3"
               }
            ]
         }
      }
   },
   "response" : {}
}
!, 'print the grid on failure';





# done_testing;
