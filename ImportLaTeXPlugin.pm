package TWiki::Plugins::ImportLaTeXPlugin;
use strict;

use vars qw( $VERSION $RELEASE $SHORTDESCRIPTION $debug $pluginName $NO_PREFS_IN_TOPIC );
$VERSION = '0.1';
$RELEASE = '0.1';
$SHORTDESCRIPTION = 'Import .tex files, converts to a twiki topic';
$NO_PREFS_IN_TOPIC = 0;
$pluginName = 'ImportLaTeXPlugin';

sub Table_Parse #parse table as from LaTeX to HTML/TWiki
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
		$returntext .= "<tr>";
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
		$returntext .= "</tr>";
		}
	}
	
	return $returntext;
}

sub New_Parse#Split file at tags, parse both splits in a recurse way, think merge sort but parsing rather than sorting
{
	my ($text,@status) = @_;
	my @oldstatus = @status;#status stack need for nested formats
		
			if($text=~ /^\s*$/)#Whitespace
			{
				return ""; 
			}
			
			if($text=~ /((\n|.)*)\\begin\{document\}((\n|.)*)/)#beginning of document body
			{
				push (@status, "main");#push current status as main body
				return "".New_Parse($3,@status);#split and parse
			}
			elsif($text=~ /((\n|.)*?)\%((.)*)(\n)?((\n|.)*)/)#commented text, will not appear in topic, but appear in source
			{
				return New_Parse($1,@status)."<!--".$3."-->".New_Parse($6,@status);
			}
			elsif($text=~ /((\n|.)*)\\begin\{equation\}((\n|.)*)\\end\{equation\}((\n|.)*)/)#equations are handled by LaTeX Plugin Mode as they required advance formatting
			{
				return New_Parse($1,@status)."%BEGINLATEX%\n".$3."\n%ENDLATEX%".New_Parse($5,@status);
			}
			elsif($text=~ /((\n|.)*)\\includegraphics\[(.*)\]\{(.*)\}((\n|.)*)/)#Image tags
			{
				#$3 needs to be parsed
				return New_Parse($1,@status)."<img $3 src='%ATTACHURL%/".$4."' alt='$4' />".New_Parse($5,@status);#Image needs to be attached also
			}
			elsif($text=~ /((\n|.)*)\\begin\{tabular\}\{((.)*)\}((\n|.)*)\\end\{tabular\}((\n|.)*)/)#tables
			{
				return New_Parse($1,@status)."<table border=1>".Table_Parse($5,$3)."</table>".New_Parse($7,@status);
			}
			elsif($text=~ /((\n|.)*)\\begin\{enumerate\}((\n|.)*)\\end\{enumerate\}((\n|.)*)/)#numbered list
			{
				push (@status, "enumerate");
				return New_Parse($1,@oldstatus)."<ol>".New_Parse($3,@status)."</ol>".New_Parse($5,@oldstatus);
			}
			elsif($text=~ /((\n|.)*)\\begin\{itemize\}((\n|.)*)\\end\{itemize\}((\n|.)*)/)#bulleted list
			{
				push(@status, "itemize");
				return New_Parse($1,@oldstatus)."<ul>".New_Parse($3,@status)."</ul>".New_Parse($5,@oldstatus);
			}
			elsif($text=~ /((\n|.)*)\\begin\{description\}((\n|.)*)\\end\{description\}((\n|.)*)/)#definition list
			{
				push (@status, "description");
				return New_Parse($1,@oldstatus)."<dl>".New_Parse($3,@status)."</dl>".New_Parse($5,@oldstatus);
			}
			elsif($text=~ /((\n|.)*)\\begin\{flushright\}((\n|.)*)\\end\{flushright\}((\n|.)*)/)#right alignment
			{
				push(@status, "rightalign");
				return New_Parse($1,@oldstatus)."<p align='right'>".New_Parse($3,@status)."</p>".New_Parse($5,@oldstatus);
			}
			elsif($text=~ /((\n|.)*)\\begin\{center\}((\n|.)*)\\end\{center\}((\n|.)*)/)#left alingment
			{
				push(@status, "centeralign");
				return New_Parse($1,@oldstatus)."<p align=\"center\">".New_Parse($3,@status)."</p>".New_Parse($5,@oldstatus);
			}
			elsif($text=~ /((\n|.)*?)\\item((.)*)(\n)?((\n|.)*)/)#item tag, used by list and definitions
			{
				if(pop @status eq "description")
				{
					my $itemline = $3;
					my $startline = $1;
					my $endline = $6;
					$itemline =~ /\[(.*)\](.*)/;
					push(@status,"defitem");
					return New_Parse($startline,@oldstatus)."<dt>".New_Parse($1,@status)."</dt>"."<dd>".New_Parse($2,@status)."</dd>".New_Parse($endline,@oldstatus);
				}
				else
				{
					push(@status,"listitem");
					return New_Parse($1,@oldstatus)."<li>".New_Parse($3,@status)."</li>".New_Parse($6,@oldstatus);
				}	
			}
			elsif($text=~ /((\n|.)*?)((\\textit)|(\\textbf)|(\\section)|(\\subsection))\{((\n|.)*)/)#these are treated as the same tag because they end with an ambiguous "}"
			{
				if($3 eq "\\textit")
				{
					push(@status,"ital");
					return New_Parse($1,@oldstatus)."<i>".New_Parse($8,@status);
				}
				elsif($3 eq "\\textbf")
				{	
					push(@status,"bold");
					return New_Parse($1,@oldstatus)."<b>".New_Parse($8,@status);
				}
				elsif($3 eq "\\section")
				{	
					push(@status,"section");
					return New_Parse($1,@oldstatus)."<h1>".New_Parse($8,@status);
				}
				elsif($3 eq "\\subsection")
				{	
					push(@status,"subsection");
					return New_Parse($1,@oldstatus)."<h2>".New_Parse($8,@status);
				}
			}
			elsif($text=~ /((\n|.)*?)[\}]((\n|.)*)/)#the ambiguos "}"
			{
				my $layer = pop @status;
				if($1=~ /((\n|.)*)\\end\{document/)#sometimes checks for "}" before \end{document} this fixes that
				{	
					return $1."\n";
				}
				if($layer eq "ital")
				{
					return $1."</i>".New_Parse($3,@status);
				}
				elsif($layer eq "bold")
				{
					return $1."</b>".New_Parse($3,@status);
				}
				elsif($layer eq "section")
				{
					return $1."</h1>".New_Parse($3,@status);
				}
				elsif($layer eq "subsection")
				{
					return $1."</h2>".New_Parse($3,@status);
				}
				else
				{
					return $1."</error>".New_Parse($3,@status);
				}
			}
			elsif($text=~ /((\n|.)*?)(\\\\|\\hfill)((\n|.)*)/)#newlines / break lines
			{
				return New_Parse($1,@status)."<br/>".New_Parse($4,@status);
			}
			elsif($text=~ /((\n|.)*)"\\end\{document\}/)#end of document
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
    my($session, $params, $theTopic, $theWeb) = @_;
	my $filename = $params->{_DEFAULT};
	my $filetext = TWiki::Func::readFile("../pub/".$theWeb."/".$theTopic."/".$filename);
	my $print_text = $filetext;
	my @status;
	push @status,"Start";
	
	return New_Parse($print_text,@status);
}