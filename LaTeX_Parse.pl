#!/usr/bin/perl

#Programmer: Dwight F. Jones
#Date: 09/15/2011
#Program: Quote_Retrieve
#Purpose: pull stock information from web and print to screen or file

my $global_status="Main";

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
		
		print $schema;
		
	for $i (0..$#splitline)
	{
		if(!($splitline[$i] =~ /^\s*$/))
		{
		$returntext .= "\n<tr>\n";
		@splittext = split /&/, @splitline[$i];
		for $j (0..$#splittext)
		{
			print "\nPING!:@splitschema[$j]\n";
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
				return "<body>\n".New_Parse($3,@status);
			}
			elsif($text=~ /((\n|.)*?)\%((.)*)(\n)?((\n|.)*)/)
			{
				return New_Parse($1,@status)."\n<!--".$3."-->\n".New_Parse($6,@status);
			}
			elsif($text=~ /((\n|.)*)\\begin\{equation\}((\n|.)*)\\end\{equation\}((\n|.)*)/)
			{
				return New_Parse($1,@status)."\n%BEGINLATEX%\n<br>\n".$3."\n<br>\n%ENDLATEX%\n".New_Parse($5,@status);
			}
			elsif($text=~ /((\n|.)*)\\begin\{tabular\}\{((.)*)\}((\n|.)*)\\end\{tabular\}((\n|.)*)/)
			{
				return New_Parse($1,@status)."\n<table border=1>".Table_Parse($5,$3)."</table>\n".New_Parse($7,@status);
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
				$global_status = "end";
				return $1."\n";
			}
			return $text;

}


#sub Parse_LaTeX
#{
#	my $text = $_[0];
#	my $newtext = "";
#	my $return_text ="";
#	if($text=~ /\\begin\{document\}((\n|.)*)\\end\{document\}/)
#	{
#		$newtext = $1;
#		$text = Parse_LaTeX($newtext);
#	}
#	elsif($text=~ /\\begin\{equation\}((\n|.)*)\\end\{equation\}/)
#	{
#		$newtext = $1;
#		$return_text = "%BEGINLATEX%".Parse_LaTeX($newtext)."%ENDLATEX%";
#		$text =~ s/\\begin\{equation\}((\n|.)*)\\end\{equation\}/$return_text/;
#	}
#	elsif($text=~ /\\textit\{((\n|.)*)\}/)
#	{
#		$newtext = $1;
#		$return_text = "<i>".Parse_LaTeX($newtext). "</i>";
#		$text =~ s/\\textit\{((\n|.)*)\}/$return_text/;
#	}
#	elsif($text=~ /\\textbf\{((\n|.)*)\}/)
#	{
#		$newtext = $1;
#		$return_text = "<b>".Parse_LaTeX($newtext). "</b>";
#		$text =~ s/\\textbf\{((\n|.)*)\}/$return_text/;
#	}
#	return $text;
#}


sub print_to_file
{
	my $filename = @_[0];
	local $/=undef;
	open (FILE, "$filename.tex") or die "$! error trying to overwrite";
	binmode FILE;
	$text = <FILE>;
	open (WRITEFILE, ">$filename.html") or die "$! error trying to overwrite";
	if($text=~ /\\title\{((\n|.)*?)\}/)
	{
		print WRITEFILE "<html>\n<head>\n<title>$1</title>\n</head>\n"
	}
	else
	{
		print WRITEFILE "<html>\n<head>\n<title>No Title</title>\n</head>\n"
	}
	print WRITEFILE New_Parse($text,"Ping");
	close WRITEFILE;
}

print_to_file(@ARGV[0]);