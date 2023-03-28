#!/usr/bin/perl -w

BEGIN {
	push @INC, "/var/www/tota/";
}

no warnings 'uninitialized';

use XPortal;
&XPortal::handler();
