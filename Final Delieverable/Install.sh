

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
            tar -xvf ImportCSVPlugin.tar.gz 
    ;;
    b|B)    echo "Install Import LaTeX Plugin"
            tar -xvf ImportLaTeXPlugin.tar.gz 
    ;;
    c|C)    echo "Install Import Watermark Plugin"
            tar -xvf ImportWatermarkPlugin.tar.gz 
    ;;
    d|D)    echo "Install all TWiki plugins"
            tar -xvf ImportCSVPlugin.tar.gz 
            tar -xvf ImportLaTeXPlugin.tar.gz 
            tar -xvf ImportWatermarkPlugin.tar.gz 
      *)    echo "You did not choose a, b, c, d"
      ;;
esac
