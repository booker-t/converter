#!/usr/bin/perl

BEGIN {
	push @INC, '/var/www/tota'
}

use strict;
use warnings;

use XPortal::General;
use XPortal::Settings;

print XPortal::General::SetLock("$XPortal::Settings::TMPPath/converter.lock");

my $status;

#$status = system("/usr/bin/perl /var/www/tota/scripts/convert.pl");

#print $status, "\n";