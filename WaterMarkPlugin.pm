package TWiki::Plugins::WaterMarkPlugin;
use strict;
#use TEXT::CSV;
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
    
	my $opacity = $params->{Opacity};
	if(!$opacity)
	{
		$opacity = 10;
	}
	my $opacdeg = $opacity/100;
	my $text = $params->{Text};
	my $image = $params->{Image};
	
	my $print_text = "<literal><div style=\"position:fixed; top:30%; left:40%; opacity:$opacdeg; filter:alpha(opacity=$opacity); font-size:3em; font-color: black;\">";
	
	if($image)
	{
		$print_text .= "<img src=\"%ATTACHURL%/Johnny_Bravo_by_BGGaLaXy.jpg\" width = \"525 px\" height=\"375 px\" alt=\"watermark\"/>"
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