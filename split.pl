#!/usr/bin/perl

sub parse_line
{
	my $line = @_[0];
	my @linesplit;
	my $parseline = "";
	my $textsize = 0;
	my $textstatus= 0;
	
	if($line =~ m/\<img(.*)(\>)?/)
	{
		print "Ping!";
		my ($width, $height) = 0;
		if($2 =~ /width=\"(\d*)\"/)
		{
			$width = $1;
		}
		if($2 =~ /height=\"(\d*)\"/)
		{
			$height = $1;
		}
		$parseline .= "IMAGE{".$width.",".$height."} ".parse_line($5);
	}
	else
	{
		@linesplit = split /\s/, $line;
		for $i (0..$#linesplit)
		{
			if($linesplit[$i] =~ /(---(\+{1,6}))/)
			{	
				$textsize = 7 - length($2);
			}
			elsif($linesplit[$i] =~ /\*(.)*\*/)
			{	
				$parseline .= "WORD{". (length($linesplit[$i])- 2) .",".$textsize.",B} ";
			}
			else
			{
				$parseline .= "WORD{".length($linesplit[$i]).",".$textsize.",".$textstatus."} ";
			}
		}
	}
	return $parseline;
}

my $filename = "split.txt";
local $/;
open (FILE, "$filename") or die "$! error trying to overwrite";
$text = <FILE>;
open (WRITEFILE, ">$filename.html") or die "$! error trying to overwrite";

$text =~ s/\\\n//g;
@splittext = split /\n/, $text; 

for $i (0..$#splittext)
{

	if( $splittext[$i] =~ /^\s*$/)
	{
		print WRITEFILE "LINE_BREAK\n------------------------------------------------\n";
	}
	else
	{	
		print WRITEFILE $splittext[$i]."\n";
		$splittext[$i]=~ s/\n|\\\n//;
		print WRITEFILE parse_line( $splittext[$i] )."\n------------------------------------------------\n";
	}
}