
# NAME

LedgerSMB - Small and Medium business accounting and ERP

# SYNOPSIS

LedgerSMB is a free integrated web application accounting system, featuring
double entry accounting, budgetting, invoicing, quotations, projects, timecards,
inventory management, shipping and more ...

The UI allows world-wide accessibility; with its data stored in the
enterprise-strength PostgreSQL open source database system, the system is know
to operate smoothly for businesses with thousands of transactions per week.
Screens and customer visible output are defined in templates, allowing easy and
fast customization. Supported output formats are PDF, CSV, HTML, ODF and more.

Directly send orders and invoices from the built-in e-mail function to your
customers or RFQs (request for quotation) to your vendors with PDF attachments.


# System requirements

## Server

 * Perl 5.10+
 * PostgreSQL 9.4+
 * Web server (e.g. nginx, Apache, lighttpd)

The web external server is only required for production installs;
for evaluation purposes a simpler setup can be used, as detailed
below.

## Client

A [Dojo 1.10 compatible web browser](http://dojotoolkit.org/reference-guide/1.10/releasenotes/1.10.html#user-agent-support)
is all that's required on the client; it includes Chrome as of version 13,
FireFox as of 3.6 and MS Internet Explorer as of version 8 and a wide range of
mobile browsers.

# Quick start

The instructions below are for getting started quickly; the [project's
site](http://ledgersmb.org) provides [in-depth installation instructions](http://ledgersmb.org/topic/installing-ledgersmb-15)
for production installs.

## System (library) dependencies

The following non-Perl (system) dependencies need to be in place for the
```cpanm``` command mentioned below to work, in addition to what's documented
on the [How to install CPAN modules](http://www.cpan.org/modules/INSTALL.html)
page on CPAN.

 * PostgreSQL client libraries
 * Either:
   * PostgreSQL development package (so cpanm can compile DBD::Pg)
   * DBD::Pg (so cpanm recognises that it won't need to compile it)

Then, some of the features listed below have system requirements as well:

 * latex-pdf-ps depends on these binaries or libraries:
   * latex (usually provided through a texlive package)
   * pdflatex
   * dvitopdf
   * dvitops
   * pdftops
 * latex-pdf-images
   * ImageMagick

## Perl module dependencies

To install the Perl module dependencies, run:

```bash

 $ cpanm --notest --with-feature=starman [other features] --installdeps .

```
The following features may be selected by
specifying ```--with-feature=<feature>```:

| Feature          | Description                         |
|------------------|-------------------------------------|
| latex-pdf-ps     | Enable PDF and PostScript output    |
| latex-pdf-images | Image size detection for PDF output |
| starman          | Starman Perl/PSGI webserver         |
| openoffice       | OpenOffice.org document output      |
| edi              | (EXPERIMENTAL) X12 EDI support      |
| rest             | (EXPERIMENTAL) RESTful webservices  |

Note: The example command contains ```--with-feature=starman``` for the
purpose of the quick start.

Those who don't want to install the dependencies globally should
investigate [local::lib](http://search.cpan.org/~haarg/local-lib-2.000019/)
to create an "overlay" over the system packages in a separate
directory.

The [in-depth installation instructions](http://ledgersmb.org/topic/installing-ledgersmb-15)
contain a list of distribution provided packages to reduce the CPAN
installation.

**NOTES**
For the pdf-ps target, LaTeX is required.
For the pdf-images target, ImageMagick is  required.

## PostgreSQL configuration

The ```pg_hba.conf``` file should have at least these lines in it:

```plain
local   all                            postgres                         peer
local   all                            all                              peer
host    all                            postgres        127.0.0.1/32     reject
host    all                            postgres        ::1/128          reject
host    postgres,template0,template1   all             127.0.0.1/32     reject
host    postgres,template0,template1   all             ::1/128          reject
host    all                            all             127.0.0.1/32     md5
host    all                            all             ::1/128          md5
```

After editing the ```pg_hba.conf``` file, restart the PostgreSQL server:

```bash
 $ sudo service postgresql restart
 # -or-
 $ sudo /etc/init.d/postgresql restart
```

While it's possible to use LedgerSMB with the standard ```postgres``` user,
it's good practice to create a separate 'LedgerSMB database administrator':

```plain
$ sudo createuser --no-superuser --createdb --login \
          --createrole --pwprompt lsmb_dbadmin
Enter password for new role: ****
Enter it again: ****
```

## Running Starman

With the above completed, the system is ready to run the web server:

```bash
 $ starman tools/starman.psgi
2016/05/12-02:14:57 Starman::Server (type Net::Server::PreFork) starting! pid(xxxx)
Resolved [*]:5000 to [::]:5000, IPv6
Not including resolved host [0.0.0.0] IPv4 because it will be handled by [::] IPv6
Binding to TCP port 5000 on host :: with IPv6
Setting gid to "1000 1000 24 25 27 29 30 44 46 108 111 121 1000"
```
## Next steps

The system is installed and ready for [preparation for first
use](http://ledgersmb.org/topic/preparing/preparing-ledgersmb-15-first-use).

# Project information

Web site: [http://ledgersmb.org/](http://ledgersmb.org)

Forums: [http://forums.ledgersmb.org/](http://forums.ledgersmb.org/)

Mailing list archives: [http://archive.ledgersmb.org](http://archive.ledgersmb.org)

Mailing lists:
 * [https://lists.sourceforge.net/lists/listinfo/ledger-smb-announce](https://lists.sourceforge.net/lists/listinfo/ledger-smb-announce)
 * [https://lists.sourceforge.net/lists/listinfo/ledger-smb-users](https://lists.sourceforge.net/lists/listinfo/ledger-smb-users)
 * [https://lists.sourceforge.net/lists/listinfo/ledger-smb-devel](https://lists.sourceforge.net/lists/listinfo/ledger-smb-devel)
 
Repository: https://github.com/ledgersmb/LedgerSMB

## Project contributors

Source code contributors can be found in the project's Git commit history
as well as in the CONTRIBUTORS file in the repository root.

Translation contributions can be found in the project's Git commit history
as well as in the Transifex project Timeline.


# Copyright

```plain
Copyright (c) 2006 - 2016 The LedgerSMB Project contributors
Copyright (c) 1999 - 2006 DWS Systems Inc (under the name SQL Ledger)
```

# License

[GPLv2](http://open-source.org/licenses/GPL-2.0)