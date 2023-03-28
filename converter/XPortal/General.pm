package XPortal::General;
use strict;

use Encode;
use MIME::Words;
use MIME::Lite;
use Email::Valid;
use Fcntl qw (:flock);

sub CheckValidEmail {
	my $Email = shift;

	my $check = Email::Valid -> address($Email);
	return ($check ? 1 : 0);
}

sub SendMail {
	my $Email = shift;
	my $Subject = Encode::encode('cp1251', Encode::decode('utf8', shift()));
	my $AttachPath = shift || undef;
	my $AttachMimeType = shift; #text/csv
	my $AttachFN = shift;

	#print "$AttachPath\n";
	#print "$AttachFN\n";

	$Subject = MIME::Words::encode_mimewords($Subject, Charset => "windows-1251");
	$Subject =~ s/\?=\s+=\?windows-1251\?Q\?/_/gi;

	#my $TXTContent = '';
	#my $HTMLContent = '';

	my $msg = MIME::Lite -> new (
		From	=> "admin\@tota.systems",
		To	=> $Email,
		Subject => $Subject,
		Type	=> $AttachPath ? 'multipart/mixed' : 'multipart/alternative'
	);

	#my $part = MIME::Lite -> new(
	#	Type	 => 'TEXT',
	#	Data	 => "$TXTContent",
	#	Encoding => 'quoted-printable'
	#);

	#$part->attr("content-type.charset" => "windows-1251");
	#$msg->attach($part);

	#unless($AttachPath) {
	#	my $part1 = MIME::Lite -> new(
	#		Type	 => 'text/html',
	#		Data	 => "$HTMLContent",
	#		Encoding => 'base64'
	#	);
	#	$part1 -> attr('content-type.chaset' => "windows-1251");
	#	$msg -> attach($part1);
	#}

	#if ($AttachPath) {
	my $part2 = MIME::Lite -> new(
		Type		=> "$AttachMimeType",
		Path		=> "$AttachPath/$AttachFN",
		Filename	=> "$AttachFN",
		Disposition	=> 'attachment'
	);
	$msg -> attach($part2);
	#}

	#print $msg -> as_string;

	MIME::Lite -> send("sendmail", $XPortal::Settings::SendMailPath);

	if ($^O =~ /MSWin32/) {
		open(OUTFILE, ">", $XPortal::Settings::TMPPath."/message.eml");
		print OUTFILE $msg -> as_string;
		close(OUTFILE);
	} else {
		$msg -> send;
	}
}

my $PidFile;
sub SetLock {
    $PidFile = shift;
    open FLOCKPIDFILE, ">$PidFile" || die "$!";
    unless (flock FLOCKPIDFILE, LOCK_EX | LOCK_NB) {
	close FLOCKPIDFILE;
	return undef;
    }
    return undef;
}

sub ReleaseLock {
    flock(FLOCKPIDFILE, LOCK_UN);
    close FLOCKPIDFILE;
    unlink $PidFile;
}

1;