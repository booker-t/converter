package XPortal::Settings;
use strict;

our $Path = $^O =~ /MSWin32/ ? 'C:/Tota' : '/var/www/tota';
our $TMPPath = "$Path/tmp/";
our $ScriptsPath = "$Path/scripts";

our $DBHost_master = $^O =~ /MSWin32/ ? "localhost" : "localhost";
our $DBPort_master = $^O =~ /MSWin32/ ? 3306 : 3306;
our $DBName_master = $^O =~ /MSWin32/ ? 'tota' : 'tota';
our $DBLogin_master = $^O =~ /MSWin32/ ? 'admin' : 'admin';
our $DBPWD_master = $^O =~ /MSWin32/ ? 'kI6M3!I^2uZ6' : 'kI6M3!I^2uZ6';

our $SIDCryptKey = 'jksdhf83hklas-bhjakf873rjksac23e';

our $MailerFromEmail = 'admin@tota.systems';
our $SendMailPath = $^O =~ /MSWin32/ ? "c:/bin/sendmail/sendmail.exe -t" : "/usr/sbin/sendmail -oi -t -oem -f$MailerFromEmail";

1;