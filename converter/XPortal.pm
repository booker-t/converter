package XPortal;

BEGIN {
	push @INC, '/var/www/tota';
}

use strict;
use CGI;
use CGI::Cookie;

my $SID;
my $Cookie;
my @Cookies;

use XPortal::Settings;
use XPortal::DB;
use XPortal::General;

sub handler {
	my $query = new CGI;

	$query -> initialize_globals;

	$SID = $query -> param('sid') || $query -> cookie('SID');

	XPortal::DB::ConnectDB() unless $XPortal::DB::dbh;

	$SID = &GetRandID unless $SID;

	$Cookie = new CGI::Cookie(
		-name	 => "SID",
		-value   => $SID,
		-expires => "+180d"
	);

	push @Cookies, $Cookie;

	print $query -> header(
		-CHARSET 	=> 'utf-8',
		-type	 	=> 'text/html',
		'Cache-Control' => "no-cache",
		-cookie 	=> \@Cookies
	);

	my $filename;
	my $sendEmail;
	my $upload_filehandle;
	my $status;

	if ($query -> param('action') eq 'convert') {
		$filename = $query -> param('convert_file') || undef;
		$sendEmail = $query -> param('email') || undef;

		$filename =~ s{.*[\/\\](.*)}{$1};

		if ($filename && $sendEmail && XPortal::General::CheckValidEmail($sendEmail)) {

			XPortal::DB::DBQuery("dbh",
				"INSERT INTO files (sid, name, uploaded, email, is_new) VALUES(?,?,NOW(),?,1)",
				$SID, $filename, $sendEmail
			);

			$upload_filehandle = $query -> upload('convert_file');

			open UPLFILE, ">$XPortal::Settings::TMPPath/$filename";
			while (<$upload_filehandle>) 
			{
				print UPLFILE;
			}
			close UPLFILE;

			#$status = system("/usr/bin/perl /var/www/tota/scripts/convert.pl");
		}

	}

	print qq{<html><head><title>Конвертер</title></head>}.
		qq{<body>}.
		qq{<table border="0" cellpadding="2" cellspacing="2" style="margin-left:auto;margin-right:auto;">}.
		qq{<tr><td align="center">Конвертер ТОТА СИСТЕМС beta</td></tr>}.
		qq{<tr><td align="center">(Конвертация excel-файлов из асдку НТЦА2И)</td></tr>}.
		qq{<tr><td align="center"><form method="POST" enctype="multipart/form-data">}.
			qq{<input type="hidden" name="action" value="convert"/>}.
			qq{<table border="0" cellpadding="2" cellspacing="2">}.
#			qq{<tr><td>Тип файла:</td><td><input type="radio" id="ntca2i" name="type"/><label for="ntca2i">НТЦА2И</label>&#160;&#160;<input type="radio" id="tota" name="type"/><label for="tota">ТОТА</label></td></tr>}.
			qq{<tr><td>Файл для конвертации: </td></td><td><input type="file" name="convert_file"/></td></tr>}.
			qq{<tr><td>E-mail для отправки: </td><td><input type="text" name="email" value="$sendEmail"/></td></tr>}.
			qq{<tr><td colspan="2" align="right"><input type="submit" name="send_file" value="Конвертировать"/></td></tr>}.
			qq{</table>}.
		qq{</form></td></tr>}.
		qq{<tr><td style="color:#FF0000">Если сконвертированный файл так и не пришел на почту, перепроверьте ваши данные или обратитесь к администратору системы!</td></tr>}.
		qq{</table>}.
		qq{</body>}.
		qq{</html>};
}

sub GetRandID {
	my $RandID = '';
	use Digest::MD5 qw(md5 md5_hex md5_base64);

	my $UUID = XPortal::DB::DBQuery("dbh", "SELECT uuid()") -> fetchrow();

	$RandID = Digest::MD5::md5_hex($UUID.":".$XPortal::Settings::SIDCryptKey);
	return $RandID;
}

return 1;