package TWiki::Plugins::WaterMarkPlugin;
use strict;
use vars qw( $VERSION $RELEASE $SHORTDESCRIPTION $debug $pluginName $NO_PREFS_IN_TOPIC );
$VERSION = '0.1';
$RELEASE = '0.1';
$SHORTDESCRIPTION = 'Inserts a watermark on a TWiki topic';
$NO_PREFS_IN_TOPIC = 0;
$pluginName = 'WaterMarkPlugin';


sub initPlugin {
    my( $topic, $web, $user, $installWeb ) = @_;
	
	TWiki::Func::registerTagHandler( 'WATERMARK', \&_WATER );
	
    return 1;
}

sub _WATER {
	my($session, $params, $theTopic, $theWeb) = @_;
    
	my $opacity = $params->{opacity};
	if(!$opacity)
	{
		$opacity = 10;
	}
	my $opacdeg = $opacity/100;#need for Internet Explorer
	my $text = $params->{text};
	my $image = $params->{image};
	my $width = $params->{width};
	my $height = $params->{height};
	
	#this plugin is simple, it adds a div that acts as a watermark, that is all
	my $print_text = "<literal><div style=\"position:fixed; top:20%; left:35%; opacity:$opacdeg; filter:alpha(opacity=$opacity); font-size:3em; font-color: black;\">";
	
	if($image)
	{
		if ($height && $width)
		{
			$print_text .= "<img src=\"%ATTACHURL%/".$image."\" width = \"".$width." px\" height=\"".$height."\" alt=\"watermark\"/>";
		}
		else
		{
			$print_text .= "<img src=\"%ATTACHURL%/".$image."\" height = '480 px' width = '672 px' alt=\"watermark\"/>";
		}
	}
	elsif($text)
	{
		$print_text .= $text;
	}
	else
	{
		$print_text .= "Publishing TWiki:<br> $theTopic";
	}
	
	$print_text .= "</div></literal>";
	
	return $print_text;
}
