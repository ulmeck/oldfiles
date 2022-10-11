#!/usr/bin/perl
# bibelot.pl 

my $VERSION = "0.94";
my $URL="http://sourceforge.net/projects/bibelot";

#
#
# Format ASCII text, esp. Project Gutenberg (http://www.promo.net/pg) etexts, 
# into a PalmDoc PDB file.
#
#
#
# Copyright (C) 2000,2001 John Fulmer <jfulmer@appin.org>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# A full copy of the GNU Public License may be found at: 
#
# http://www.gnu.org/copyleft/gpl.html
#
#
#
# This program was written using documentation and structures borrowed 
# from Paul J. Lucas' 'txt2pdbdoc' (http://www.best.com/~pjl/software.html) 
# and documentation from the Pyrite website 
# (http://www.pyrite.org/etext/format.html). Also, 'pdbdump' was invaluable in 
# troubleshooting format problems.
#
# Some of the header structures were borrowed, but the programming is my fault.
# If it breaks, you keep both pieces. But let me know. I'm especially interested
# in formatting problems, and trying to track down all the different cases I
# can.
# 
# Oh, and what is a 'bibelot'? 
# See http://www.dictionary.com/cgi-bin/dict.pl?term=bibelot or your nearest
# dictionary.
#
#
# jf
#
#
# Version History:
#
#	.01		Initial (ugly) version
#
#	.02		-Partial re-write, made more modular
#			-Added option to turn compression off (-c)
#			-Added verbose (-v)
#			-Added option to set document name (-l)
#			-Added option to disable document formatting (-f)
#			-Added usage message (-h)
#			-Improved compression slightly
#			
#
#	.03		-Added 'Project Gutenberg' (-g) mode, which sets
#				the beginning of actual text as a bookmark.
#			-Now adds two NULL characters between the PDB record
#				headers and the first record (Record 0).
#			-Initial bookmark support.
#	
#	.04 10/4/00	-Various cleanups
#			-Added filename sanity checks, and read/write checking
#			-Improved text formatting efficiency.	
#			-Fixed bug that didn't collapse whitespace correctly
#			-Fixed off-by-one bug if forcing line lengths.
#			-Fixed incorrect use of 'pack' that required 
#			 	'no strict'.
#			-Gutenberg mode now sets chapter bookmarks, if able.
#			-Added dynamic bookmark support (-b). 
#			 Place text to bookmark
#			 in between angle brackets (<>). The script will
#			 search for the first instance of the text, and
#			 create a bookmark using the text as the bookmark
#			 name. One bookmark per line, please.
#
#			 For instance, let's see you wanted a bookmark
#			 at text that says "Fit The First". At the bottom
#			 of the origional text file, on a blank line, 
#			 place a "<Fit The First>". The script will
#			 Bookmark the first instance of "Fit The First"
#			 in the document, and erase the "<Fit The First>"
#			 at the bottom of the file. The text is case
#			 sensitive.
#
#			-Adjusted 'smart' format function
#
#	.5 10/6/00	-Work around (bug in Perl5?) where the :^ascii:
#			 regex class was matching "[", and stripping it
#			 from text.
#			-changed version number to match Freshmeat announcement
#			 (whoops)	
#			-removed spurious 's' option from getopts() 
#
#	.6		-re-added option to turn off 'smart' format mode. (-s)
#			 (Found out what that spurious 's' was for)
#			-added code to rejoin words split by hyphens at eol.
#
#	.7 12/21/00	-automagically grab title (if not specified with -t) 
#			 from file in 'Project Gutenberg' mode. Often 
#			 (but not always) the title is specified on the
#			 first line of a text from Project Gutenberg.
#			 Grab it, truncate (if necessary),plunk it into
#			 the DOC title field.
#                       -added -d option to turn off hypen correction
#			-modified help option and added to opening comments.
#			-verbose now echo's detected title.
#			-a few code cleanups.
#
#	.8 1/4/00	-match more title entries from Project Gutenberg
#	  		-now hosted at Sourceforge, and development versions
#			 in CVS.
#			-more (minor)tweaks to the smart formatting, to help 
#			 with badly formatted text with short lines early on.
#			-fixed bug that didn't strip out non-ascii chars.
#			 Yes, Virginia, octal DOESN'T stop at 255.....
#
#	.9 1/9/00	-Code cleanups.
#			-Strips control characters from title text.
#			-More sanity checks on output filename. If infile or 
#			 outfile are NULL, treat them as stdin/stdout.
#			-You can now use '-' to specify stdin or stdout
#			-Better compression. Thanks to Antaeus Feldspar, the 
#			 compression algorithm is more efficient. It also makes
#			 bibelot a bit slower (6 seconds vs 4.5 seconds on an
#			 average book file on my system). The efficiencies only
#			 add up to %1-2 better compression, but that's 4-10k for
#			 many books, which can add up.  
#			-Compression error debugger, also courtesy Antaeus 
#			 Feldspar. Turn on by the $error_check global variable.
#			-New switch, 'o', to seed smart formatting offset. The 
#			 smaller the number, the better (maybe) the formatting,
#			 but more badly chopped lines. Default is 20.
#			-Handle another different title for PG mode.
#
#	.91		-Minor code change, Palm desktop for Windows demands
#			 a timestamp in the PDB header. I faked up one 
#			 (0x11111111) for now. In the process, I also learned
#			 that ActiveState Perl build 623 doesn't work with 
#			 with bibelot, something to do with a difference in
#			 string handling. ActiveState's problem, if you ask me.
#			 I would be interested if bibelot works on anything else
#			 besides Linux, though... I DO know that nsperl 5.004
#			 for dos works fine. 
#
#	.92 2/26/01	-More minor changes for DOS and Windows versions of perl
#			 now it actually works. Uses binmode() for output if 
#			 DOS/Win32 platform. (Are you happy now, Kyle?!?)
#			-Added check for common DOS and Win32 versions of 
#			 perl, currently only looks for ActiveState's Perl 
#			 for Win32, others probably work. 
#			-Disabled filename sanity checks for Win32 platforms.
#			-Accidentally left the compression error checking on.
#			 Should be MUCH faster now.
#
#
#	.93 4/02/01	-Condensed the title match regex to one line.
#			-Fixed problem with spaces in title with '-t'
#
#	.94 5/18/01	-Added 8-bit support. This removes the check for high
#			 byte control characters, so don't blame me if your
#			 Palm blows up. :)
#
#
#
# Pragma goes HERE
#
# 'Use strict' so that we have to declare variables. Not a bad practice.
#

use strict;


#
# Global Variables go HERE
#

my $total_len = 0;			# Total length of uncompressed text
my $buff = "";				# Temporary buffer space
my $header = "";			# PDB headers to preappend
my $is_compr = 1;			# '0' = no, '1' = yes
my $is_verbose = 0;			# If set, output debug info.
my $dont_format = 0;			# Don't format the text
my $infile = "-";			# file to read, or STDIN (-)
my $outfile = ">-";			# file to write to, or STDOUT (>-)
my $line_len = 0;			# If set, force linefeeds at $line_len
my $pdb_name = "PalmDoc Document";	# Name of PalmDoc file
my $col_position = 0;			# Global column position for format
my @block_size;				# Compressed size of all text blocks
my $avg_line_num = 0;			# The next three are for use in
my $avg = 0;				# format_text()'s formatting logic.
my $avg_total = 0;
my $is_pg = 0;				# 'Project Gutenberg' mode. Adds
					# A bookmark autoscan tag to the end of
					# the text to indicate the start of
					# the real text.
my $pg_pos = 0;
my $bookmark_buff = "";			# Temporary buffer for bookmark
my $bookmark_num = 0;			# Total number of bookmarks
my $is_bookmark = 0;			# Switch for bookmark mode
my $is_smart = 1;			# Switch to turn off 'smart' format
my $title_set = 0;			# Is title name set?
my $pg_title;				# Title for PG mode
my $pg_title_set = 0;			# Found $pg_title
my $is_hyphen_off = 0;			# Switch to turn off hypen correction
my $sformat_offset = 20;		# Smart format offset
my $error_check = 0;			# Compr. error checker
my $is_evil = 0;			# Check for Microsoft OS's

#################################################################
#								#
# 			Main program				#
#								#
#################################################################

#
# Process 'getopts' and return global variables
#

proc_opts() || die "Arg! Confusing command options (should never happen!)\n";

#
# Read text from input source into buffer. Yes, all of it. And format it.
#

$buff = read_text() || 
	die "Arg! Error in reading text (should never happen!)\n";

#
# Create optional bookmarks
#

if ($is_pg || $is_bookmark) { $bookmark_buff = find_bookmarks($buff); } 

#
# Compress, if necessary.
#

if ($is_compr) { $buff = compr_text($buff); }

#
# Generate PDB headers and record 0, and pre-append them to the buffer.
#

$buff = pdb_header() . $buff;

#
# Write optional bookmarks
#

if ($is_pg || $is_bookmark) { $buff .= $bookmark_buff; }

#
# Write text out
#

write_text($buff)|| 
	die "Arg! Error in writing file (should never happen!)\n"; ;


# Done. Wasn't that easy.



#################################################################
#								#
#	Get and process command line options			#
#								#
#################################################################


sub proc_opts {

#
# Local Variables
#

my $num_args;

#
# Turn off 'strict' for getopts().
#

no strict;

#
# getopts() is your friend
#

use Getopt::Std qw(getopt getopts);
getopts('l:vdht:cfgbso:') || die "Invalid Argument\n";

#
# Force line length? 
#

if ($opt_l) {				# Not empty
   unless ($opt_l =~ /\D/) {		# And only contains digits
   	$line_len = int($opt_l);
   } else {				# is alpha or otherwise	
	die "Invalid line length.\n";
   }
}

#
# Help text
#

if ( $opt_h ) {

	print "\nusage: $0 [OPTIONS] <infile> <outfile>\n\n" .
	"Formats text to PalmDoc format.\n" .
	"$URL\n" .
	"Version $VERSION\n\n" .
	"options:\n" .
	"\t-h\t\tthis message\n" .
	"\t-c\t\tturn file compression OFF\n" .
	"\t-v\t\tverbose\n" .
	"\t-t \"title\"\tdocument title\n" .
	"\t-f\t\tdon't format text\n" .
	"\t-l<n>\t\tforce line width to <n> bytes\n" . 
	"\t-g\t\tEnable 'Project Gutenberg' mode\n" .
	"\t-b\t\tEnable Dynamic Bookmark mode\n" .
	"\t-d\t\tTurn off hyphen correction\n" .
	"\t-s\t\tTurn off 'smart' format\n" .
	"\t-o<n>\t\tOffset for 'smart' format (default '20')\n\n" .
	"Use '-' or omit filenames to indicate STDIN or STDOUT.\n\n";
	exit 0;
}	

#
# Set document name
#

if ( $opt_t ) {

$opt_t =~ s/[\000-\011\013-\037\177-\377]//g;	#strip control chars
$opt_t =~ s/\s+/ /g;

	if ( (length $opt_t) > 31 ) {
		$pdb_name = substr($opt_t,0,28) . "...";
		$title_set = 1;  
	} else {
		$pdb_name = $opt_t;
		$title_set = 1;
	}
}	

#
# Set offset for 'smart' filtering. The larger the number, the more formatted
# text it may miss (due to the shorter length), but you will get fewer false
# positives due to short lines.
#

if ($opt_o) {				# Not empty
   unless (($opt_o =~ /\D/) ||		# And only contains digits
          (int($opt_o) > 65))  {	# Offsets greater than 65 are worthless
   	$sformat_offset = int($opt_o);
   } else {				# is alpha or otherwise	
	die "Invalid offset.\n";
   }
}

if ($opt_v) { $is_verbose = 1; }      	# Maximum Verbosity!
if ($opt_c) { $is_compr = 0; }		# Turn off compression?	
if ($opt_f) { $dont_format = 1; }	# Don't format text
if ($opt_g) { $is_pg = 1; }		# Project Gutenberg mode	
if ($opt_b) { $is_bookmark = 1; }	# Bookmark mode
if ($opt_s) { $is_smart = 0; }		# Turn off 'smart' format
if ($opt_d) { $is_hypen_off = 1; }	# Turn off hyphen correction

#
# Turn back on strict
#

use strict;

#
# Check for the 'Evil' OS...or OS/2 or whatever...
#

if ($^O =~ /MSWin32|dos|os2/i) { $is_evil = 1 }


#
# Everything left should be file names, or an error

$num_args = @ARGV;

#
# use filenames or STDIN/STDOUT?
#

if ($num_args == 0) {		# No args?
	$is_verbose = 0;	# Turn off verbosity 
				# defaults are good for STDIN/STDOUT
	
}elsif ($num_args == 1) {	# 1 arg? Must be for infile
	$infile = sanitize($ARGV[0], "input");
	$is_verbose = 0;	# Turn off verbosity

}elsif ($num_args == 2){	# 2 args? Must be both infile/outfile
	$infile = sanitize($ARGV[0], "input");
	$outfile = sanitize($ARGV[1], "output");

}else {				# More? Error and die!
	die "Too many filename arguments on command line.\n";
}	


#
# Return 'success' code
#

return(1);

}	



#################################################################
#								#
#		Read text from input into buffer.		#
#								#
#################################################################


sub read_text {

#
# Local Vars HERE
#

my $in;			# Buffer to store text in.
			
			
open (IN, "$infile") || die "Can't open $infile: $!\n";
while (<IN>) {

#
# Format and add each line to $in
#

  if ($dont_format) {			# Don't format text
	  $in .= $_;
  } else {		
	  $in .= format_text($_);
  }
}

close (IN);


#
# Set $total_len for header generation
#

$total_len = length $in;

return ($in);

}


#################################################################
#								#
#			Write text out to file.			#
#								#
#################################################################

sub write_text {

open (OUT, ">$outfile") || die "Can't open $outfile: $!\n";

if ($is_evil) { binmode(OUT) }		# Make MS OS's happy

print OUT $_[0];			# Output the file
close (OUT);
return (1);

}


#################################################################
#								#
#		Format text to a more PalmDoc reader 		#
#		friendly format.				#
#								#
#################################################################

sub format_text {

#
# Local Vars HERE
#


my $line_buff = "";			# Temorary buffer to format text in
my @line;
my $x;
my $y;
my $testchar;
my $newx = "";

#
# Function to take a line of text (in $_[0]), strip out extra 
# linefeeds and such and, if necessary, add linefeeds to give 
# max -l # chars per line. Must also maintain a global (col_position) 
# to make sure that when this function is reentered, 
# we know on what column position we left off last time.
#



#
# Grab title from text, first one that matches, wins.
#

if (($is_pg) && !($pg_title_set)){
	$pg_title = $_[0];
	if ( 
    $pg_title =~ s/.+?Project Gutenber(g|g's) Etext( | of) (.+?)(by|,|,by|\*|\.).+/$3/i
	   )

	{
	   chop $pg_title;
	   if ( (length $pg_title) > 31 ) {
	      $pg_title = substr($pg_title,0,28) . "...";
           }
	   $pg_title_set = 1;
	}  
}	

#
# Assign input string to @line, remove ending newlines, split by whitespace
#

chomp;
@line = split(/\s+/, $_[0]);

#
# Attempt at some formatting logic. If average line size is somewhat over 80, 
# we can safely assume that the file is not formatted, and any linefeeds we 
# find should stay right where they are, since they are probably formatting.
# 
# If we find the average size is ~ 80 or under, but the linefeed comes somewhat
# under the average size, we will guess the linefeed stays.
#
#

if (length($_[0]) > 30) {			# Ignore short lines
	$avg_total +=  length($_[0]);
	$avg = $avg_total / ++$avg_line_num;
}


#
# Check each word, strip any whitespace characters, and insert
# a newline before the word if it would cross the $line_len boundary.
#
# Then add the word to the output string.
#
# Note that some text may be mangled, if it depends on hard returns for 
# formatting, or double spaces. 
#

foreach $x (@line) {

	if ($x)  {
		if ($is_smart) {
                  $x =~ s/\s+?|[\000-\011\013-\037]//g;
		}
						# Ixnay spaces, control chars
						# tab/space formatted text will
						# certainly break. 

#
# If forcing to a specific line length, check to see if adding the word
# and space will overflow the specified line length. If so, add newline first
# and reset the col_position counter.
#

		if ( $line_len && 
		     (((length $x) + $col_position + 1) > $line_len) ) {
			$line_buff .= "\n";
			$col_position = 0;
		}

#
# Add word + space to output buffer, then increment the column position
#

			$line_buff .= $x  . " ";	
			$col_position += (length $x) + 1;  
		
	}
	

		
}


unless ($is_hyphen_off) {
   $x = length $line_buff; 
   $line_buff =~ s/-\s+\Z//;			# fix hypen separated words at
						# the end of lines.
   $col_position += $x - (length $line_buff);	# Adjust for hypen removal
}						

#
# If the output string contains no words, assume a double spaced line
# otherwise, replace the final newline.
#

if ( $avg > 85 ) { 
	$line_buff .= "\n";				# Preserve linefeeds if
	$col_position = 0;				# file appears to
}							# already be stripped.

if (($line_buff eq "") && ($col_position != 0)) {	# Double space 
	$line_buff = "\n\n";
	$col_position = 0;

} elsif ($line_buff eq "") {				# Single space
	$line_buff = "\n";
	$col_position = 0;
	
#
# This is some VooDoo that seems to work well. So far. 
#
# What it does is this: Using average line size information at the top of this 
# function, it assumes that lines that are less than the average -
# $sformat_offset AND if the current column position (where the linefeed would 
# go) is less than the average - $sformat_offset , it assumes that it is a 
# formatted line, and inserts the linefeed. The further into the file it goes, 
# the more accurate it should be.
#
# I can imagine all kinds of places where this would break horribly,
# but it would break anyway without this bit's help.
#	

} elsif ( ((length $line_buff) <= $avg - $sformat_offset ) && 
	  ($col_position <= $avg - $sformat_offset ) &&
	  ($avg < 85) &&
	  ($is_smart) ) {			# Assume formatted text
	$line_buff .= "\n";
	$col_position = 0; 
}


return ($line_buff);

}


#################################################################
#								#
#		Generate the PDB headers and Record 0		#
#								#
#################################################################


sub pdb_header {

#
# Local Vars HERE!
#

#
# Some constants
#


my $COUNT_BITS = 3;
my $DISP_BITS = 11;
my $DOC_CREATOR = "REAd";
my $DOC_TYPE = "TEXt";
my $RECORD_SIZE_MAX = 4096;	# 4k record size
my $dmDBNameLength = 32;	# 32 chars + 1 null

my $pdb_rec_offset;		# PDB record offset
my $header_buff = "";		# Temporary buffer to build the headers in.
my $x;
my $y;

#
# PDB header
#
# We're going to set some variables and then use 'pack' to put them into a
# buffer.
#
# Here's the format in C (Dword = 4 bytes, Word = 2 bytes)
#
#typedef struct {                /* 78 bytes total */
#        char    name[ dmDBNameLength ];
#        Word    attributes;
#        Word    version;
#        DWord   create_time;
#        DWord   modify_time;
#        DWord   backup_time;
#        DWord   modificationNumber;
#        DWord   appInfoID;
#        DWord   sortInfoID;
#        char    type[4];
#        char    creator[4];
#        DWord   id_seed;
#        DWord   nextRecordList;
#        Word    numRecords;
#} pdb_header;

my $pdb_header_size = 78;
my $pdb_attributes = 0;
my $pdb_version = 0;
my $pdb_create_time = 0x11111111;			# Palm Desktop demands
my $pdb_modify_time = 0x11111111;			# a timestamp.
my $pdb_backup_time = 0;
my $pdb_modificationNumber;
my $pdb_appInfoID = 0;
my $pdb_sortInfoID = 0;
my $pdb_type = $DOC_TYPE;
my $pdb_creator = $DOC_CREATOR;
my $pdb_id_seed = 0;
my $pdb_id_nextRecordList = 0;
my $pdb_numRecords = (int ($total_len / 4096)) + 2; 	# +1 for record 0
							# +1 for fractional part
if ($is_pg || $is_bookmark) { $pdb_numRecords += $bookmark_num; }

#
# Pack that header!
#

#
# Set $pdb_name to detected name, unless forced using -t.
#

if ( !($title_set) && ($is_pg) && ($pg_title_set)) {
	$pdb_name = $pg_title;
	
}	

if ($is_verbose) {
	print "Document Title: $pdb_name\n";
}	
	
						
my $pdb_header = pack("a32nnNNNNNNa4a4NNn",$pdb_name,$pdb_attributes,
					 $pdb_version,$pdb_create_time,
					 $pdb_modify_time,$pdb_backup_time,
					 $pdb_modificationNumber,$pdb_appInfoID,
					 $pdb_sortInfoID,$pdb_type,$pdb_creator,
					 $pdb_id_seed,$pdb_id_nextRecordList,
					 $pdb_numRecords);


#
# Sanity check
#

if ( (length $pdb_header) != 78) { die "pdb_header malformed\n"; }

#
# Create the PalmDoc header
#
#
# Here's the format in C
#
# struct doc_record0 {      /* 16 bytes total */
#            Word   version;      /* 1 = plain text, 2 = compressed text */
#            Word   reserved1;
#            DWord  doc_size;     /* uncompressed size in bytes */
#            Word   num_recs;     /* not counting itself */
#            Word   rec_size;     /* in bytes: usually 4096 (4K) */
#            DWord  reserved2;
#       };



my $doc_header_size = 16;
my $doc_version = $is_compr + 1;		# Compression on by default
my $reserved1 = 0;
my $doc_doc_size = $total_len;
my $doc_rec_size = 4096;
my $doc_num_recs = (int ($total_len / 4096)) + 1;	
my $doc_reserved2 = 0;

# 
# Pack Record 0
#


my $doc_header = pack("nnNnnN",$doc_version,$reserved1,$doc_doc_size,
			     $doc_num_recs,$doc_rec_size,$doc_reserved2);


#
# Sanity check!
#

if ( (length $doc_header) != 16) { die "doc_header malformed\n"; }

#
# Template for the PDB record headers
#
# Docs are REAL fuzzy on this.
#
#
# Format in C
#
#struct pdb_rec_header {   /* 8 bytes total */
#      DWord  offset;
#      struct {
#             int delete    : 1;
#             int dirty     : 1;
#             int busy      : 1;
#             int secret    : 1;
#             int category  : 4;
#      }      attributes;
#      char   uniqueID[3];
#}

my $pdb_rec_header_size = 8;
my $pdb_rec_attributes = 0x40;		# We'll fake this, 0x40 = 'dirty'
my $pdb_rec_uniqueID = 0x3D0;		# Simple increment

#
# Since we need to so a bunch of these, we'll use this as a template
#

my $pdb_rec_header_template = "Nccn";


#
# Generate and write headers
#
#
# PDB record headers are generated and placed at the head of the file. 
# The number of headers required is Total_File_Bytes / 4096 + 1
# The +1 being for the fractional part left over.
#
# Someone could have documented this better. :)
#
# For the record, the file format is:
#
#	PDB Header (78 bytes)
#		PDB  Record Headers (8 bytes)
#		. . .
#		. . .	Repeat N + B + 1 times, where N is # of 4096K  blocks
#		. . .		The +1 is for record 0 (DOC header)
#		. . . 		B = # of bookmarks
#			(DB Records)
#			0x0 0x0		Two NULLS 
#			Record 0 (PalmDoc Header)
#			Text
#			. . .
#			. . .
#			. . .
#			Optional Bookmark records
#			. . .	
#			EOF
#
#

	$pdb_rec_offset = $pdb_header_size + 
			  (($pdb_numRecords)* $pdb_rec_header_size) + 2;

#
# Write PDB header, and PDB rec header for record 0
#
	
	$header_buff = $pdb_header . pack($pdb_rec_header_template,
					  $pdb_rec_offset, $pdb_rec_attributes,
					  "a",$pdb_rec_uniqueID );
	$pdb_rec_offset += $doc_header_size;	# Add offset for doc_header

	if ($is_pg || $is_bookmark) { $pdb_numRecords -= $bookmark_num;}
	
	for ($x = 0; $x < $pdb_numRecords - 1; $x++) {	
					# -1 for rec 0 header added above

#
# If we aren't compressing, every other block besides 0 is guarenteed to be 
# $RECORD_SIZE_MAX
#
		if (! $is_compr && $x > 0 ) 
			{ $block_size[$x] = $RECORD_SIZE_MAX; }
			
		$pdb_rec_offset += $block_size[$x];
		++$pdb_rec_uniqueID;
		$header_buff .=	pack($pdb_rec_header_template,$pdb_rec_offset,
				     $pdb_rec_attributes,"a",$pdb_rec_uniqueID);
	}
	
# 
# Write optional bookmark pdb headers
#

if (($is_pg || $is_bookmark) && $bookmark_num) {

	if ($is_compr){				# Find the end of the text	
		$pdb_rec_offset += $block_size[$x];
	} else { 
		$pdb_rec_offset += $total_len % 4096;
		}
	for ($y = 0; $y < $bookmark_num; $y++) {
			
		$pdb_rec_uniqueID += 10;
		$header_buff .= pack($pdb_rec_header_template,$pdb_rec_offset,
			        $pdb_rec_attributes,"a",$pdb_rec_uniqueID);
		$pdb_rec_offset += 20;		# Bookmarks are 20 bytes.	
	}			
}
			     	
#
# Write 2 NULLS
#

	$header_buff .= 0x00 . 0x00;

# Write Record 0

	$header_buff .= $doc_header;	



return ($header_buff);


}


#################################################################
#								#
#		Compress the text				#
#								#
#################################################################

sub compr_text {


#
#
# Compresses text with the PalmDoc compression scheme.
#
# Requires:
#		$_[0], which contains the entire text to be compressed.
#
# Returns:	$compr_buff, which contains the compressed text.
#		global @block_size, Array that contains the length of each 
#		compressed block.
#		'scalar(@block_size)' should be = to $pdb_numRecords

#
# Local Vars HERE!
#

my $total_compr_size = 0;		# Final compressed text size
my $compr_buff = "";			# Temporary output buffer
my $numrecords = (int($total_len / 4096) +1);	# Number of blocks to compress.
my $x;
my $y;
my $block_offset;
my $block;			# Contains the current 4096 byte block of text
my $block_len;			# Length of current block
my $index;			# Current scan position in block
my $byte;			# Char at index (for space + char compression)
my $byte2;			# Char at index+1
my $test;			# Potentially compressible text for 
				# LZ77 compression.

my $frag_size;			# Current size of above
my $frag_size2;			# Spare for lazy byte compression	
my $test2;			# spare for above
my $test3; 			# second spare				
my $pos;			# Position (in $block) of reference text 
				# for $test
				# to compress against.

my $pos2;			# spare for above
my $pos3;			# second spare
my $back;			# $index - pos
my $mask;			# Bitwise mask to do LZ77 'magic'
my $compr_ratio;		# Compression ratio
my $done;				
my $comp_block_offset = 0;	# The $compr_buff index
				# block begins.
my $FRAG_MAX = 10;		# Max LZ77 fragment size
my $FRAG_MIN = 3;		# Min LZ77 fragment size
my $LAZY_BYTE_FRAG = $FRAG_MAX + $FRAG_MIN - 1;

								
$block_size[0] = 0; 		# Record 0 is already written and 
				# is not compressed.


for ($x = 1; $x <= $numrecords; $x++) {

	$block_offset = ($x - 1) * 4096;
	$block = substr($_[0],$block_offset, 4096);
	if ($x >= $numrecords) {			# Last block
		$block = substr($block,0,($total_len % 4096));

	}
		
$block_len = length($block);	

#
# Tricky PalmDoc compression scheme. Here's the overview:
#
# Given a compressed stream, read a byte.
# The byte will lie in the following zones:
# 0       represents itself
# 1...8   type A command; read the next n bytes
# 9...7F  represents itself
# 80..BF  type B command; read one more byte
# C0..FF  type C command; represent "space + char"
#
#
# Sooo. If we just write ASCII text, it will fall within 9..7F or 0 (NULL). 
# No worries.
#
# If we write 1...8, the next n bytes will be taken as verbatim. This is 
# used to mask high byte characters, like accents. I'm not a-using them
# at this point. High byte characters get stripped in the text processing 
# function.
#
# If we write C0..FF, it will be treated as a space + character. 
# Write the space, then xOR 0x80, should work.
#
# 80..BF is tricky. A 16 bit number is written:
#	Throw away	offset		   bits to copy (+3)
#		0 0|0 0 0 0 0 0 0 0 0 0 0|0 0 0	
#
# So. To encode we keep an index of where we currently are in the file, 
# and constantly check 3-10 char fragments from $index+frag_size against 
# the text in $index - 2047 of a 4096 byte block, which contains the 
# uncompressed text. 
#
# If we find a match, we generate the above gobblygook, (that is, place the
# offset into a packed INT (2 bytes), shift it 3 places, then place the number
# of bits to copy from the offset in the lower three bits of the INT) place 
# it in the compressed buffer, increment the index accordingly (# of bits 
# compressed), and go from there. 
# Whee.
#

$index = 0;

#
# Compression loop
#


while ( $index < $block_len ) {


	
#	
# Type 'A', Escape high bytes
#	
	$byte = substr($block,$index,1);	# Char at $index
	if ($byte =~ /[\200-\377]/) {   # is high bit set?

		$y = 1;			# found at least one!

#			
# Loop to find out how many concurrent high bit characters, max 8
#			
		while ( (substr($block,$index + ($y + 1),1)  =~ 
			      /[\200-\377]/) &&
			($y < 8) ) {

			++$y;		# If found, increment counter
				 	
		}			

		$compr_buff .= chr($y); # Write escape code
		$compr_buff .= substr($block,$index,$y); # Write text
		$index += $y;		# Increment the index		

	 } else { 			# Real compression routines

#
# Type 'B', simple LZ77 compression
#	
	$frag_size = $FRAG_MIN;		# We don't care about anything less

	$test = substr($block,$index,$frag_size); # pull the current fragment
	$pos = rindex($block, $test, $index - 1); # check against the buffer

		
# 
# There's a sliding window of 2047 bytes that we can pull reference 
# characters from.
#
	
	if ( ($pos > 0) &&		 	
	     ($index - $pos <= 2047) && 	# Inside our 2047 byte window
	     ( $index < $block_len - $frag_size) ) { 

#						# Found a match!
# looking for bigger fragments						
#
		for ($y = 4; $y <= $FRAG_MAX; $y++ ) { 
			++$frag_size ;
			$test2 = substr($block,$index,$frag_size);
			$pos2 = rindex($block, $test2, $index - 1);
			if (($pos2 > 0) && 
			    ($index - $pos2 <= 2047) && 
			    ($index < $block_len - $frag_size) ) { 
						# found a match!
				$pos = $pos2;
				$test = $test2;
			} else {		# no match, go back
				--$frag_size;
				last;
				
			}
			 
		}
						# Sanity check		
		if ($frag_size > $FRAG_MAX) 
		  { die "frag_size too big!!!: $frag_size\n"; }	
		  
		  
#
# Now look for an even better match starting at the next position.		
# This is known as 'lazy matching'.
#


# NOTE:  Why is ($STD_FRAG_MAX + $STD_FRAG_MIN - 1) so magic?
# Let's pretend that we are currently at index 1001, looking for matches.
# The longest match we can find for the text starting at 1001 has a length of 3.
# If the longest match we can find for the text starting at 1002 has a length of
# 10, then obviously we get better compression by sending the byte at 1001 out
# as a literal and encoding the match found at 1002.  But if the longest match
# for the text starting at 1002 has a length of 12 ($STD_FRAG_MAX + $STD_FRAG_MIN - 1,
# for the PalmDoc spec) then we can encode the match we find for the text at 1001
# and *still* have a match of length 10 for the text starting at 1004.


	   $frag_size2 = $frag_size + 2;
	   $test2 = substr($block,$index + 1, $frag_size2);
	   $pos2 = rindex($block, $test2, $index - 1);
	   if (($pos2 > 0) && 
		    ($index - $pos2 <= 2047) && 
		    ($index < $block_len - $frag_size2) ) { 
							# found a match
		
		   for ($y = $frag_size2;$y <= $LAZY_BYTE_FRAG; 
		        $y++ ) { 		# Look for more
			++$frag_size2;
			$test2 = substr($block,$index + 1, $frag_size2);
			$pos2 = rindex($block, $test2, $index - 1);
			if (($pos2 > 0) && 
			    ($index - $pos2 <= 2047) && 
			    ($index < $block_len - $frag_size2) ) { 
							# found a match!

			} else {			# no match, go back
				--$frag_size2;
			        last;
				
			}			    		       
		   }
		  if ($frag_size2 < $LAZY_BYTE_FRAG)  {	
		  
#
# Lazy byte found; write byte to output and abort compression round
#
		       $pos = 0;		
		       $compr_buff .= substr($block,$index,1);	
		       ++$index; 
		  }
	    }	  		
		
	   if ($pos > 0) {		# Did we abort the compression?
		
		
#
# Figure out how far to reach back into the buffer, and create OR mask 
# that sets the high bit and indicates how big the compressed fragment is.
#			
	      $back = $index - $pos;
	      $mask = 0x8000 | int($frag_size - 3);

#
# This line does all the magic; munge and add to output buffer
#
	      $compr_buff .= pack("n",int($back << 3) | $mask);
	      $index += $frag_size;
	   }
	   
	} else {



#	
# Type 'C', Space + Char compress
#	
		$byte = substr($block,$index,1);	# Char at $index
		$byte2 = substr($block,$index + 1,1);	# next char as well
		if ( ($byte eq " ") && 
		     ($byte2 =~ /[\100-\176]/ ) && 
		     ($index <= $block_len - 1)) {
		       					# Got a space + char
						
							# Set the high bit
							# and add to output 
							# buffer.
	         		$compr_buff .= pack("c", ord ($byte2) | 0x80 );
				$index += 2;		# Compressed 2 bytes
	
		} else {
			$compr_buff .= $byte;		# No compression
		     	++$index; 
		}
	}
}
}


#
# Check for errors in the compression routine then move the counter that 
# identifies where the compressed representation of the most recently handled 
# block starts. Turn on by setting $error_check to '1'
#

if ($error_check) {
	check_comp($block, substr($compr_buff, $comp_block_offset));
        $comp_block_offset = length($compr_buff);

}

if ( $is_verbose ) {
  $| = 1;						# Flush output buffers
  $done = int(($x / ((length $_[0]) / 4096)) * 100);
  if ($done > 100) {$done = 100;}
  print  "\rBlock: $x\tComplete: $done%";
}  

#
# Calculate compressed block sizes, and the total compressed size of the file
#

$block_size[$x] = (length ($compr_buff)) - $total_compr_size;
$total_compr_size = length ($compr_buff);

if ( $is_verbose ) {
  $done = int(($block_size[$x] / $block_len) * 100);
  print "\tCompressed: $done%";
}

$| = 0;							# Flush buffers off

}	 

#
# And one linefeed for Ra....
#

if ($is_verbose) { print "\n"; }


#
# Print some useless information
#

if ($is_verbose ) { 
	$compr_ratio = ($total_compr_size / $total_len) * 100 ;
	print "Original Size: $total_len\tCompressed Size: $total_compr_size\t";
	printf ("Reduced: %.2f%\n", $compr_ratio);
}

	
return ($compr_buff);	

}

#################################################################
#								#
#		Generate Bookmark Headers			#
#								#
#################################################################

sub bookmark_rec {


#
# For now, we are only going to find the end of Gutenberg Project "Fine Print"
# text and set it as a bookmark.
#

# 
# Local Vars HERE
#

#my $book_pg = "*END*THE SMALL PRINT!";
my $book_pg = $_[1];
my $book_name = "Bookmark $bookmark_num";	# Default bookmark name

if ($_[2]) { $book_name = $_[2];}	# Bookmark name was passed to function.

my $book_pos = $_[3];			# Offset from start of text to place bm	
my $book_header_size = 20;		# Size of Bookmark header
my $book_buff = "";			# Output buffer

unless ($book_pos) {			# If bookmark position not passed
$book_pos = (index($_[0],$book_pg)) + 1; # Index starts at 0, DOC readers 1
}

#
# Make sure the bookmark name is 15 chars or less
#

if (length $book_name > 15) {$book_name = substr($book_name,0,12) . "...";}

if ($book_pos > 0) {
	$book_buff = pack("a16N",$book_name,$book_pos);
	++$bookmark_num;
	return ($book_buff);
} else {
	return ("");			# No bookmark
}	

}


#################################################################
#								#
#		Sanitize filename entries			#
#								#
#################################################################


sub sanitize {

#
# Do various checks on filename entries. Strip control characters, substitute
# underscores for most forms of punctuation.
#
# Recieves filename or path + filename to process, whether is it a input file
# or output file, and returns the sanitized version.
#
#

#
# Local vars HERE
#
chomp; 				# Just to be safe;

my $filename = $_ = $_[0];
my $io = $_[1];
my $junk;
my $path = $filename;

#
# If input file, all we care about is that the file exists, is a text file
# and readable. For the output file, we want to sanitize the filename, 
# and make sure the destination directory is writable.
#

if ($is_evil) { return ($_) }	# MS OS. Ack! Game over! No sanity for you!

if ($io =~ /in/i) {				# Input file
   if ($filename && $filename ne "-" ) {	# and not null or "-"
 	unless ( -e $filename && -r $filename )
     { die "Input file IO error: $filename $!\n";}
   } else {					# is null
     $_ = "-";					# stdin
   }     
		
} elsif ($io =~ /out/i) { 			# Output file
    if ($filename) {  				# and not null
    	$junk = eval "tr#\-/.a-zA-Z0-9#_#cs";
	if (m#/#) {				# contains a path.
		$path =~ s#^(.*/).*#$1#;	# Strip filename from path
		unless (-w $path) 
		  { die "Output file IO error: Output directory unwritable\n";}
	}
	unless ( (!(-e $filename)) || -w $filename ) # Not exist or writable
		{ die "Output file IO error: Output file unwritable\n";}
    } else { 					# is null
        $_ = ">-";				# stdout
    }	
} else {					# Shouldn't get here.
	die "Error in sanitize function\n";	
}


return ($_);

}

#################################################################
#								#
#		Find Bookmarks					#
#								#
#################################################################

sub find_bookmarks {

my $pg_bookmark = "*END*THE SMALL PRINT!";
my $pg_bookmark_name = "Text Begins";
my $bookmark_rec = "";

if ($is_pg) {

#
# Set 'start of text' bookmark
#					
$bookmark_rec .= bookmark_rec($_[0],$pg_bookmark,$pg_bookmark_name);

#
# Find and set chapter bookmarks
#
	while ($_[0] =~ /\n((?:chapter|chaptre).*?)\s*?\n/gi ) {

		if ($is_verbose) { 
			print "Bookmark: $1\t\tOffset: " . pos($_[0]) . "\n";
		}	
		$bookmark_rec .= bookmark_rec($_[0],"$1","$1",pos($_[0]) -
						length($1));
	}	

}

if ($is_bookmark) {

	while ($_[0] =~ /\n<(.+?)>/g ) {
	
		if ($is_verbose) { 
			print "Bookmark: $1\n";
		}
		$bookmark_rec .= bookmark_rec($_[0],"$1","$1");
	}
	$_[0] =~ s/\n<(.+?)>//g;
	

}

return ($bookmark_rec);

}


#################################################################
#								#
#		Compression Error Checking			#
#								#
#################################################################


sub check_comp ($$) {

#
# Compares the original block to one that's been compressed and decompressed
# and reports any places where they differ.
#
# Requires:
#		$original_block, the formatted block that was originally sent 
#		to be compressed. Passed to the subroutine as a parameter
#		
# 		$comp_block, the compressed version of the block
#		Passed to the subroutine as a parameter
#
# Returns:	Nothing.  Output from this routine goes to standard output.
#
#
#

#
#
# Local Vars HERE!
#

my $original_block = $_[0];
my $comp_block = $_[1];
my $roundtrip_block = ""; 	# buffer for decompressed text.
my $comp_index = 0; 		# index for start of next element in $comp_block
my $element;			# element read from the compressed data stream
my $bytes_added = 0;		# the number of bytes added to the output

my $pair_var;			# integer used to hold the two-byte packed pair.
my $offset;			# used if B compression is encountered.
my $length;			# used if B compression is encountered.

my $i;				# simple loop variable


while ($comp_index < length($comp_block)) {
  $element = substr($comp_block, $comp_index, 1);

#  
# decompress the next element:
#
   if ((ord($element) == 0x00) ||		# Literal byte range
      ((ord($element) >= 0x09) && 
       (ord($element) <= 0x7F))) {

#		
# output the literal byte.
#

      $roundtrip_block .= $element;
      $bytes_added = 1;
      $comp_index += 1;
      
   } elsif ((ord($element) >= 0x01) && 		# 'A' (escaped) code range
            (ord($element) <= 0x08)) {

#		
# Copy next $element bytes literally. (shouldn't happen at this point)
#			

      $roundtrip_block .= substr($comp_block, $comp_index + 1, ord($element));
      $bytes_added = ord($element);
      $comp_index += (1 + $bytes_added);
      
   } elsif ((ord($element) >= 0x80) && 	 	# 'B' (LZ77) code range
            (ord($element) <= 0xBF)) {
	    
#
# read the next byte and copy the offset, length pair if it's a B code.
#

      $pair_var = ((ord($element)) << 8) + 
                    ord(substr($comp_block, ($comp_index + 1), 1));
      $offset = ($pair_var >> 3) & 0x7FF;
      $length = ($pair_var & 0x07) + 3;

#			
# sanity checks
#			

      if (($offset <= 0) or ($offset > 2047)) {		# out of window error
         die "offset is " . $offset . " at index " . 
	      (length($roundtrip_block)). "!!!\n"; 
      }
      
      if (($length < 3) or ($length > 10)) { 		# too few/too many 
         die "length is " . $length . " at index " . 	# bytes to copy error
	      (length($roundtrip_block)) . "!!!\n"; 
      }
     
      if ((length($roundtrip_block) - $offset) < 0) {	# read before start
      							# of block error
      							
         die "offset " . $offset .  " goes beyond beginning of block!!!\n"; }
#                               
# This last one would really be better if a meaningful representation of
# *where* in the file/block the offensive offset occurs could be included.
#				
						
      for ($i = 1; $i <= $length; $i++) {
         $roundtrip_block .= substr($roundtrip_block, 
	                     (length($roundtrip_block) - $offset), 1);
      }
			
      $bytes_added = $length;
      $comp_index += 2;
		
		
   } elsif ((ord($element) >= 0xC0) && 	 # 'C' (space + char) code range
            (ord($element) <= 0xFF)) { 

#		
# output the space + character
#			

      $roundtrip_block .= " ";
      $roundtrip_block .= chr(ord($element) & 0x7F);
      $bytes_added = 2;
      $comp_index += 1;
   }
	
   
} # end while

if ( $roundtrip_block ne $original_block) {
   die "Compressed text does not match original\n";
   }

} # end of check_comp
