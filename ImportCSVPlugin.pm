package TWiki::Plugins::ImportCSVPlugin;

use strict;
use vars qw( $VERSION $RELEASE $SHORTDESCRIPTION $debug $pluginName $NO_PREFS_IN_TOPIC $directory );
$VERSION = '1.0';
$RELEASE = '1.0';
$SHORTDESCRIPTION = 'Convert a CSV file to a table';
$NO_PREFS_IN_TOPIC = 0;
$pluginName = 'ImportCSVPlugin';

sub initPlugin {
    my( $topic, $web, $user, $installWeb ) = @_;

	$directory = TWiki::Func::getWorkArea( $pluginName );
    TWiki::Func::registerTagHandler( 'INSERTTABLE', \&_TABLE );
    TWiki::Func::registerTagHandler( 'INSERTCHART', \&_CHART );
	
    # Get plugin debug flag
    $debug = TWiki::Func::getPreferencesFlag( "\U$pluginName\E_DEBUG" );
	
	# Plugin correctly initialized
    TWiki::Func::writeDebug( "- TWiki::Plugins::${pluginName}::initPlugin( $web.$topic ) is OK" ) if $debug;

    return 1;
}

sub preRenderingHandler
{
### my ( $text ) = @_;   # do not uncomment, use $_[0], $_[1] instead

    &TWiki::Func::writeDebug( "- $pluginName::preRenderingHandler" ) if $debug;

    # This handler is called by getRenderedVersion just before the line loop
    # Only bother with this plugin if viewing (i.e. not searching, etc)
    return unless ($0 =~ m/view|viewauth|render|TestRunner/o);
}

#Handles the Insert table tag
sub _TABLE {

	#Session Attributes
	my($session, $params, $theTopic, $theWeb) = @_;
  
	#User Import Attributes
	my $filename = $params->{filename};#Name of CSV file
	my $header = $params->{header};#Does the table have a horizontal header
	my $rowheader = $params->{rowheader};#Does the table have a vertical header
	my $delimiter = $params->{delimiter};#The File can use an uncommon delimiter
	
	if(!$delimiter)#If no $delimiter is added, change it to , so to not cause and error
	{
		$delimiter = ",";
	}
	
	my($return_text)="";#TWiki text 
	my $filetext = TWiki::Func::readFile("../pub/".$theWeb."/".$theTopic."/".$filename);#Find the file in the attachments
	my $cnt = 0;#used with negated delimiters
	my @subsitute;#used with negated delimiters
	while($filetext =~ m/\"(((.)*?)[$delimiter|,|;]((.)*?))\"/)#If there exist "Text,More" this becomes ##@Number@##, to be replaced later 
		{
			$subsitute[$cnt] = $1;
			$filetext =~ s/\"(((.)*?)[$delimiter|,|;]((.)*?))\"/(##\@$cnt@##)/;
			$cnt += 1;
		}
	my @split_text = split /\n/, $filetext;#split file text at newline, these are the rows of a table 
	my @split_line;#Column of a table
  
	my ($i, $j, $firstline);
  
	$firstline = 0;
    
	if (@split_text == 0)#if no lines are in the file name it does not exist
	{
		return 'File Does Not Exist';
	}
	else
	{
	    $return_text = '%TABLE{name="'.$filename.'"}%'."\n";#Designates a table tag to uses this with charts
		if ($header)
		{
			$return_text .= "|";
    		@split_line = split /,|;|$delimiter/, $split_text[0];#split row into columns 
			for $j ($firstline .. $#split_line)
			{
				$return_text .= "*$split_line[$j]*|";#embolden header
			}
		$return_text .= "\n";#start new line
		$firstline++;
    }
    
    for $i ($firstline .. $#split_text)
    {
		$return_text .= "|";
      	@split_line = split /,|;|$delimiter/, $split_text[$i]; 
        for $j (0 .. $#split_line)
		{
			if ($rowheader && $j == 0)
			{
				$return_text .= "*$split_line[$j]*|";#embolden row header
			}
			else
			{
				$return_text .= "$split_line[$j]|";
			}
		}
		$return_text .= "\n";
    }
	$cnt = 0;
    while($return_text =~ m/\(##\@$cnt@##\)/)#replace negated text
	{
		$return_text =~ s/\(##\@$cnt@##\)/$subsitute[$cnt]/;
		$cnt += 1;
	}
    return $return_text;
  }
}

sub _CHART {
  #Session Variables
  my($session, $params, $theTopic, $theWeb) = @_;
  
  #User Table Variables
  my($return_text, $delimiter, $type, $data, $xaxis, $legend, $width, $height, $name);
  
  #File name
  my $filename = $params->{filename};
  
  #User Chart Variables
  $type = $params->{type};
  $name = $params->{name};
  $data = $params->{data};
  $xaxis = $params->{xaxis};
  $legend = $params->{legend};
  $width = $params->{width};
  $height = $params->{height};
  $delimiter = $params->{delimiter};
  
  
  if(!$delimiter)
  {
	$delimiter = ",";
  }
  
  my @split_text = split /\n/, TWiki::Func::readFile("../pub/".$theWeb."/".$theTopic."/".$filename);
  my @split_line;
  
  @split_line = split /$delimiter|,|;/, $split_text[0];
  

  if (!$type)#if no type is choosen, default to a bar chart
  {
    $type = 'bar';
  }
    
  $return_text = _TABLE(@_);#created table this is needed by the chart plugin
  
  if (!$params->{showtable})#if the table is not to be shown, hid it with a div tag
  {
    $return_text = '<div style="display:none;">'.$return_text.'</div>'."\n";
  }
  
  $return_text .= '%CHART{ type="'.$type.'" name="'.$name.'" table="'.$params->{filename};
  
  if ($data)
  {
	$return_text .= '" data="'.$data.'" ';
  }
  else
  {
	if ($params->{header} && $params->{rowheader})
	{
	  $return_text .= '" data="R2:C2..R'.($#split_text+1).':C'.($#split_line+1).'" ';
	}
	elsif ($params->{header})
	{
	  $return_text .= '" data="R2:C1..R'.$#split_text.':C'.$#split_line.'" ';
	}
	elsif ($params->{rowheader})
	{
	  $return_text .= '" data="R1:C2..R'.$#split_text.':C'.$#split_line.'" ';
	}
	else
	{
	  $return_text .= '" data="R1:C1..R'.$#split_text.':C'.$#split_line.'" ';
	}
  }
  
  if ($xaxis)
  {
    $return_text .= 'xaxis="'.$xaxis.'" ';
  }
  
  if ($legend)
  {
    $return_text .= 'legend="'.$legend.'" ';
  }
  
  if ($height)
  {
    $return_text .= 'height="'.$height.'" ';
  }
  else
  {
    $return_text .= 'height="200" ';
  }
  
  if ($width)
  {
    $return_text .= 'width="'.$width.'" ';
  }
  else
  {
    $return_text .= 'width="400" ';
  }
  
  $return_text .= '}%';
  
  return $return_text;
}
