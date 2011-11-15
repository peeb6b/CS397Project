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


my $mime_type = mimetype($file);

