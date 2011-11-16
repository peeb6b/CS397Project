#!/usr/bin/perl

sub parse_line
{
	my $line = @_[0];
	my @linesplit;
	my $parseline = "";
	my $textsize = 0;
	my $textstatus= 0;
	
	if($line =~ /\<img(.*)(\>)+(.*)/)
	{
		my ($width, $height) = 0;
		my $holder = $1;
		my $extra = $3;
		if($1 =~ /width=\"(\d*)\"/)
		{
			$width = $1;
		}
		if($holder =~ /height=\"(\d*)\"/)
		{
			$height = $1;
		}
		$parseline .= "IMAGE{".$width.",".$height."} ".parse_line($extra);
	}
	elsif ($line =~ /(((\s){3})+)\*(\s)(.*)/)
	{
		my $extra = $5;
		my $stringdepth = $1;
		my $depth=length($stringdepth)/3;
		$parseline .= "Bullet{".$depth."} ".parse_line($extra);
	}
	else
	{
		@linesplit = split /\s/, $line;
		for $i (0..$#linesplit)
		{
			if($linesplit[$i] =~ /^\s*$/)
			{
			}
			elsif($linesplit[$i] =~ /(---(\+{1,6}))/)
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