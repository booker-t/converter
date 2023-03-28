#!/usr/bin/perl

BEGIN {
	push @INC, "/var/www/tota";
}

use strict;
use Time::Local;
use Encode;

use XPortal::Settings;
use XPortal::General;
use XPortal::DB;

XPortal::DB::ConnectDB();

if (XPortal::General::SetLock("$XPortal::Settings::TMPPath/converter.lock")) {

    #print XPortal::General::SetLock("$XPortal::Settings::TMPPath/converter.lock");

    exit(0);
}

my $GetConvertData = XPortal::DB::DBQuery("dbh",
	"SELECT name, email FROM files WHERE is_new = 1",
);

while (my ($File, $Email) = $GetConvertData -> fetchrow()) {

    my $csv_file_name  = 'convert.csv';

    open(CSV, ">", $XPortal::Settings::TMPPath."convert.csv") || die $!;
    open(FH, "<", $XPortal::Settings::TMPPath."$File") || die $!;

    my $line = '';
    my $dataHash;
    my $ParamsList;

    while ( $line = <FH> ) {
	if ($line =~ /worksheet/i) {
	    if ( $line =~ /<row/ ) {
		my $count = 0;
		while ($line =~ /<row(.*?)row>/gi) {
		    $count++;
		    if ($count > 3) {
			my $blck = $1;
			$blck =~ /(<c.*?><v>.*?<\/v><\/c>)(<c.*?><v>\d+\.\d+\.\d+ \d\d:\d\d:\d\d<\/v><\/c>)(<c.*?><v>.*?<\/v><\/c>)/;
			my $name_str = $1;
			my $date_str = $2;
			my $value_str = $3;

			my $val = $value_str;
			$val =~ s{<c.*?>}{};
			$val =~ s{<\/c>}{};
			$val =~ s{<v.*?>}{};
			$val =~ s{<\/v>}{};

			$date_str =~ /<v>(.*?)<\/v>/;
			my $date = $1;
			#print $date, "\n";
			my ($mday, $mon, $year, $hour, $min, $sec) = split(/[\s.:]+/,$date);
			my $time = timelocal($sec, $min, $hour, $mday, $mon-1, $year);
			#print $time, "\n", scalar localtime $time;

			#$dataHash -> {$time} = [$date_str, $name_str, $value_str, $date];

			$name_str =~ s{<c.*?>}{};
			$name_str =~ s{<v.*?>}{};
			$name_str =~ s{</c>}{};
			$name_str =~ s{</v>}{};

			$ParamsList -> {$name_str} = '';

			$dataHash -> {$date} -> {$name_str} = $val;

		    }
		}
	    }
	}
    }

    #print CSV '"дата";"время";';

    print CSV Encode::encode('cp1251', Encode::decode_utf8('"дата";"время";'));

    foreach my $key (sort keys %$ParamsList) {
	#print CSV '"', $key, '";';
	print CSV '"', Encode::encode('cp1251', Encode::decode_utf8($key)), '";';

	#print $key, "\n";
    }

    print CSV "\n";

    foreach my $key (sort keys %$dataHash) {
	my ($date, $time) = split(/ /, $key);
	print CSV $date, ";", $time, ";";
	

	foreach my $param (sort keys %$ParamsList) {
	    if ($dataHash -> {$key} -> {$param}) {
		my $value = $dataHash -> {$key} -> {$param};
		$value =~ s{\.}{,};
		print CSV '"', $value, '";';
	    } else {
		print CSV '"";';
	    }
	}

	print CSV "\n";
    }

    close(FH);
    close(CSV);

    XPortal::General::SendMail($Email, 'Сконвертированный файл', $XPortal::Settings::TMPPath, 'text/csv', 'convert.csv');

    XPortal::DB::DBQuery("dbh", "UPDATE files SET is_new = 0 WHERE name = ?", $File);

}

XPortal::General::ReleaseLock();