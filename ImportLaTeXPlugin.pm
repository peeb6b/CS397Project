package TWiki::Plugins::ImportLaTeXPlugin;
use strict;
#use TEXT::CSV;
use vars qw( $VERSION $RELEASE $SHORTDESCRIPTION $debug $pluginName $NO_PREFS_IN_TOPIC );
$VERSION = '0.1';
$RELEASE = '0.1';
$SHORTDESCRIPTION = 'Import .tex files, converts to a twiki topic';
$NO_PREFS_IN_TOPIC = 0;
$pluginName = 'ImportLaTeXPlugin';

sub Table_Parse
{
	my ($text, $schema) = @_; 
	$text =~ s/\\hfill|\\hline//g;
	$text =~ s/\n//g;
	$text =~ s/\\\\/\n/g;
	$schema =~ s/\|//g;
	$schema =~ s/\s+//g;
	my $returntext = "";
	my @splitline = split /\n/, $text;
	my @splittext;
	my @splitschema= split '', $schema;
	my $align;
	my($i,$j) = 0;
		
	for $i (0..$#splitline)
	{
		if(!($splitline[$i] =~ /^\s*$/))
		{
		$returntext .= "\n<tr>\n";
		@splittext = split /&/, @splitline[$i];
		for $j (0..$#splittext)
		{
			if( @splitschema[$j] eq "l")
			{
				$align = "left";
			}
			elsif( @splitschema[$j] eq "c")
			{
				$align = "center";
			}
			elsif( @splitschema[$j] eq "r")
			{
				$align = "right";
			}
			else
			{
				$align = "center";
			}
			
			$returntext .= "<td align = '".$align."'>".$splittext[$j]."</td>";
		}
		$returntext .= "\n</tr>\n";
		}
	}
	
	return $returntext;
}

sub New_Parse
{
	my ($text,@status) = @_;
	my @oldstatus = @status;
		
			if($text=~ /^\s*$/)#Whitespace
			{
				return ""; 
			}
			
			if($text=~ /((\n|.)*)\\begin\{document\}((\n|.)*)/)
			{
				push (@status, "main");
				return "".New_Parse($3,@status);
			}
			elsif($text=~ /((\n|.)*?)\%((.)*)(\n)?((\n|.)*)/)
			{
				return New_Parse($1,@status)."<!--".$3."-->".New_Parse($6,@status);
			}
			elsif($text=~ /((\n|.)*)\\begin\{equation\}((\n|.)*)\\end\{equation\}((\n|.)*)/)
			{
				return New_Parse($1,@status)."BEGINLATEX<br />".$3."<br /> ENDLATEX".New_Parse($5,@status);
			}
			elsif($text=~ /((\n|.)*)\\begin\{tabular\}\{((.)*)\}((\n|.)*)\\end\{tabular\}((\n|.)*)/)
			{
				return New_Parse($1,@status)."<table border=1>".Table_Parse($5,$3)."</table>".New_Parse($7,@status);
			}
			elsif($text=~ /((\n|.)*)\\begin\{enumerate\}((\n|.)*)\\end\{enumerate\}((\n|.)*)/)
			{
				push (@status, "enumerate");
				return New_Parse($1,@oldstatus)."\n<ol>\n".New_Parse($3,@status)."\n</ol>\n".New_Parse($5,@oldstatus);
			}
			elsif($text=~ /((\n|.)*)\\begin\{itemize\}((\n|.)*)\\end\{itemize\}((\n|.)*)/)
			{
				push(@status, "itemize");
				return New_Parse($1,@oldstatus)."\n<ul>\n".New_Parse($3,@status)."\n</ul>\n".New_Parse($5,@oldstatus);
			}
			elsif($text=~ /((\n|.)*)\\begin\{flushright\}((\n|.)*)\\end\{flushright\}((\n|.)*)/)
			{
				push(@status, "rightalign");
				return New_Parse($1,@oldstatus)."\n<p align=\"right\">\n".New_Parse($3,@status)."\n</p>\n".New_Parse($5,@oldstatus);
			}
			elsif($text=~ /((\n|.)*)\\begin\{center\}((\n|.)*)\\end\{center\}((\n|.)*)/)
			{
				push(@status, "centeralign");
				return New_Parse($1,@oldstatus)."\n<p align=\"center\">\n".New_Parse($3,@status)."\n</p>\n".New_Parse($5,@oldstatus);
			}
			elsif($text=~ /((\n|.)*?)\\item((.)*)(\n)?((\n|.)*)/)
			{
				push(@status,"listitem");
				return New_Parse($1,@oldstatus)."<li>".New_Parse($3,@status)."</li>".New_Parse($6,@oldstatus);
			}
			elsif($text=~ /((\n|.)*?)((\\textit)|(\\textbf)|(\\section)|(\\subsection))\{((\n|.)*)/)
			{
				if($3 eq "\\textit")
				{
					push(@status,"ital");
					return New_Parse($1,@oldstatus)."\n<i>\n".New_Parse($8,@status);
				}
				elsif($3 eq "\\textbf")
				{	
					push(@status,"bold");
					return New_Parse($1,@oldstatus)."\n<b>\n".New_Parse($8,@status);
				}
				elsif($3 eq "\\section")
				{	
					push(@status,"section");
					return New_Parse($1,@oldstatus)."\n<h1>\n".New_Parse($8,@status);
				}
				elsif($3 eq "\\subsection")
				{	
					push(@status,"subsection");
					return New_Parse($1,@oldstatus)."\n<h2>\n".New_Parse($8,@status);
				}
			}
			elsif($text=~ /((\n|.)*?)[\}]((\n|.)*)/)
			{
				my $layer = pop @status;
				if($1=~ /((\n|.)*)\\end\{document/)
				{	
					return $1."\n</body>\n</html>";
				}
				if($layer eq "ital")
				{
					return $1."\n</i>\n".New_Parse($3,@status);
				}
				elsif($layer eq "bold")
				{
					return $1."\n</b>\n".New_Parse($3,@status);
				}
				elsif($layer eq "section")
				{
					return $1."\n</h1>\n".New_Parse($3,@status);
				}
				elsif($layer eq "subsection")
				{
					return $1."\n</h2>\n".New_Parse($3,@status);
				}
				else
				{
					return $1."\n</d>\n".New_Parse($3,@status);
				}
			}
			elsif($text=~ /((\n|.)*?)(\\\\|\\hfill)((\n|.)*)/)
			{
				return New_Parse($1,@status)."\n<br/>\n".New_Parse($4,@status);
			}
			elsif($text=~ /((\n|.)*)"\\end\{document\}/)
			{
				return $1."\n";
			}
			return $text;

}


sub initPlugin {
    my( $topic, $web, $user, $installWeb ) = @_;
	
	TWiki::Func::registerTagHandler( 'IMPORTLATEX', \&_IMPORT );
	
    return 1;
}

sub _IMPORT {
    #my $directory = TWiki::Func::getWorkArea( $pluginName );
	#TWiki::Func::saveFile("$directory"."/SPY.CSV","");
	my($session, $params, $theTopic, $theWeb) = @_;
	my $filename = $params->{_DEFAULT};
	my $filetext = TWiki::Func::readFile("../pub/".$theWeb."/".$theTopic."/".$filename);
	my $print_text = $filetext;
	my @status;
	push @status,"Start";
	
	return New_Parse($print_text,@status);
}