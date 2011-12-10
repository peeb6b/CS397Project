package TWiki::Plugins::ExportPlugin;
use strict;
use vars qw( $VERSION $RELEASE $SHORTDESCRIPTION $debug $pluginName $NO_PREFS_IN_TOPIC $directory );
$VERSION = '0.1';
$RELEASE = '0.1';
$SHORTDESCRIPTION = 'Export option as .pdf or .txt';
$NO_PREFS_IN_TOPIC = 0;
$pluginName = 'ExportPlugin';

# Always use strict to enforce variable scoping
use strict;

sub initPlugin {
    my( $topic, $web, $user, $installWeb ) = @_;

	$directory = TWiki::Func::getWorkArea( $pluginName );
    TWiki::Func::registerTagHandler( 'EXPORT', \&_EXPORT );
    return 1;
}

sub preRenderingHandler
{

    &TWiki::Func::writeDebug( "- $pluginName::preRenderingHandler" ) if $debug;

    # This handler is called by getRenderedVersion just before the line loop
    # Only bother with this plugin if viewing (i.e. not searching, etc)
    return unless ($0 =~ m/view|viewauth|render|TestRunner/o);
}

sub _EXPORT {
  my($session, $params, $theTopic, $theWeb) = @_;
  
  my $returntext;
  PLAINTEXT(@_);
  
  #$returntext = "<input type=\"submit\" value=\"Export as text\" onclick=\"javascript:window.open('http://minersoft.org/team1/bin/genpdf/".$theWeb."/".$theTopic.");\"/></form>";
  $returntext = "<a href=\"http://minersoft.org/team1/bin/genpdf/".$theWeb."/".$theTopic."\">Export as PDF</a>";
  
  return $returntext;
}

sub PLAINTEXT {
  my($session, $params, $theTopic, $theWeb) = @_;
	
	#Page information based on measured default variables
	my $maxheight = 10.11;
	my $maxwidth = 6.69;
	my $letterwidth = 0.075;
	my $lineheight = 0.2;

	#Object Measurements
	my $table = 0;
	my $pheight = 0;
	my $pageheight = 0;
	my $currwidth = 0;
	
	my $i;
	my @splittext;
	my $textsize;
	my $text;
	my $expandedtext;
	
	#nested sub, this is needed no where else
	sub parse_line
	{
		my $line = @_[0];
		my @linesplit;
		my $parseline = "";
		
		if($line =~ /\|(.)*\|/ || $table)
		{
			if($line =~ /\|(.)*\|/)
			{
				$table++;
			}
			else
			{
				$table = 0;
			}
		}
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
			$pheight += int($height/96);
			$pageheight += int($height/96);
			$currwidth += int($width/96);
		}
	#	elsif ($line =~ /(((\s){3})+)\*(\s)(.*)/)
	#	{
	#		my $extra = $5;
	#		my $stringdepth = $1;
	#		my $depth=length($stringdepth)/3;
	#		$parseline .= "Bullet{".$depth."} ".parse_line($extra);
	#	}
		else
		{
			@linesplit = split /\s/, $line;
			for $i (0..$#linesplit)
			{
				if( $currwidth >= $maxwidth)
				{
					$parseline .= "\n";
					$pheight += $lineheight;
					$pageheight += $lineheight;
					$currwidth = 0;
				}

				if($linesplit[$i] =~ /^\s*$/)
				{
				}
				elsif($linesplit[$i] =~ /(---(\+{1,6}))/)
				{	
					$textsize = 7 - length($2);
					$currwidth += (7 - length($2))*$letterwidth;
					$pheight += 2*$lineheight;
					$pageheight += 2*$lineheight;
				}
				elsif($linesplit[$i] =~ /\*(.)*\*/)
				{	
					$parseline .= $linesplit[$i].' ';
					$currwidth += (length($linesplit[$i]-2))*$letterwidth;
				}
				else
				{
					$parseline .= $linesplit[$i].' ';
					$currwidth += (length($linesplit[$i]))*$letterwidth;
				}
			}
		}
		return $parseline;
	}

	local $/;
	open (FILE, TWiki::Func::getDataDir()."/".$theWeb."/".$theTopic.".txt") or die "$! error trying to overwrite";
	$text = TWiki::Func::renderText(<FILE>);
	open (WRITEFILE, ">$directory/$theTopic-plaintext.txt") or die "$! error trying to overwrite";#write text to work area before making a new topic

	#$text = TWiki::Func::expandCommonVariables($text, $theTopic, $theWeb);
	$text =~ s/\\\n//g;
	$text =~ s/!%(.*?)%/\@$1@/g;#replace !%TAG% with @TAG@
	while($text =~ /(%(.*?)%)/)#Find and Exapand all twiki tags
	{
		$expandedtext = $1;
		if($expandedtext =~ /EXPORT/)
		{
			$expandedtext = "";
		}
		elsif($expandedtext =~ /META/)
		{
			$expandedtext = "";
		}
		else
		{
			$expandedtext = TWiki::Func::expandCommonVariables("$expandedtext", $theTopic, $theWeb);
		}
		$expandedtext =~ s/%(.*?)%/\@$1@/;
		$text =~ s/(%(.*?)%)/$expandedtext/;
	}
	$text =~ s/\@(.*?)@/\%$1%/g;#Replace @TAG@ with %TAG%
	@splittext = split /\n/, $text;

	for $i (0..$#splittext)
	{
		$currwidth = 0;#Current line width, how much is on the current line of text
		$pheight += $lineheight; #add the line height to the paragrah height
		$pageheight += $lineheight; #add to page height

		if( $pageheight >= $maxheight && !$table) #if page height is great then max height page Break at beginning of paragraph
		{
			print WRITEFILE "\n@-----------------------------------------------------------------------------------------@\n";
			$pageheight = 0;
		}
		
		if( $splittext[$i] =~ /^\s*$/)
		{
			$pheight = 0;
		}
		else
		{	
			$splittext[$i]=~ s/\n|\\\n//;
			print WRITEFILE parse_line( $splittext[$i] );
		}

		print WRITEFILE "\n";
	}
}
