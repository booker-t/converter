package XPortal::DB;

use strict;
use DBI;
use Carp;

our $dbh;

sub ConnectDB {
	$dbh = DBI -> connect(
		"dbi:mysql:database=$XPortal::Settings::DBName_master;host=$XPortal::Settings::DBHost_master;port=$XPortal::Settings::DBPort_master",
		$XPortal::Settings::DBLogin_master,
		$XPortal::Settings::DBPWD_master,
		{
			AutoCommit => 1,
			RaiseError => 1
		}
	) or die $!;
	$dbh -> do("SET NAMES 'utf8'");
	$dbh -> do("SET sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'");
}

sub DBQuery {
	my $Base = shift;
	my $sql_query = shift;

	my $dbh;

	if ($Base eq 'dbh') {
		$dbh = $XPortal::DB::dbh;
	} else {
		die "ERROR in DBQuery(): Incorrect Base value: '$Base' !!!";
	}

	my $sth = $dbh -> prepare($sql_query);

	eval{$sth -> execute(@_)};
	Carp::croak($@) if $@;
	return $sth;
}

1;