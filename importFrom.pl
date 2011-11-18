#!/usr/bin/perl

# Programmer: Paul Eggler
# Date:       11/14/2011
# File:       exportTo.pl
# Purpose:    This script will
#               -get the current file type
#               -call the appropriate parser.
############Requires the File::MimeInfo perl package####################

# Logic for detecting file type
#   -By file extension
#   -By mime type

use File::MimeInfo;

my $file = "HW1.docx";

# Look for file extension
$file =~ /\.([a-zA-Z0-9]*)/ ;
if ( $1 == "docx" )
{
  print "this is a docx file\n";
  # Call docx importer
}
elsif ( $1 == "tex" )
{
  print "this is a tex file\n";
}
elsif ( $1 == "txt" )
{
  print "this is a txt file\n";
}
elsif ( $1 == "csv" )
{
  print "this is a csv file\n";
}
else
{
  print "unsupported file type, nub!";
}

# If file contains no extension

# my $mime_type = mimetype($file);
# print $mime_type;

