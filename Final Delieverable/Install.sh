

# Import CSV
# Import LaTeX
# Import Watermark
# Import All

echo "Choose an option to install"
echo "a.) Import CSV"
echo "b.) Import LaTeX"
echo "c.) Import Watermark"
echo "d.) Install all plugins"
echo "---------------------------------"
echo -n "Choice: "
read answer

case $answer in
    a|A)    echo "Install Import CSV Plugin"
            gzip -dc ImportCSVPlugin.tar.gz | (umask 0; cd ..; tar xvf -)
    ;;
    b|B)    echo "Install Import LaTeX Plugin"
            gzip -dc ImportLaTeXPlugin.tar.gz | (umask 0; cd ..; tar xvf -)
    ;;
    c|C)    echo "Install Import Watermark Plugin"
            gzip -dc ImportWatermarkPlugin.tar.gz | (umask 0; cd ..; tar xvf -)
    ;;
    d|D)    echo "Install all TWiki plugins"
            gzip -dc ImportCSVPlugin.tar.gz | (umask 0; cd ..; tar xvf -)
            gzip -dc ImportLaTeXPlugin.tar.gz | (umask 0; cd ..; tar xvf -)
            gzip -dc ImportWatermarkPlugin.tar.gz | (umask 0; cd ..; tar xvf -)
      *)    echo "You did not choose a, b, c, d"
      ;;
esac
