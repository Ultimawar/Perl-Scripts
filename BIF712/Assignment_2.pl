#!/home/bif712_153a09/software/bin/perl


# Assignment Number:	    2
# Subject Code and Section: BIF712A [15-3]
# Student Name: 			Keshav Dial
# Student Number: 			102139151
# Instructor Name: 			Danny Abesdris
# Due Date: 				Friday November 27th 2015
# Date Submitted:			Thursday November 26th 2015

# Student Assignment Submission Form
# ==================================
# I declare that the attached assignment is wholly my own work
# in accordance with Seneca Academic Policy.  No part of this
# assignment has been copied manually or electronically from any
# other source (including web sites) or distributed to other students.

#Name(s)                                          Student ID(s)

#Keshav Dial										  102139151
#---------------------------------------------------------------

# This assignment represents my own work in accordance
# with Seneca Academic Policy
# Signature: Keshav Dial

#Purpose: The purpose of this assignment is to extract information
#		  from a form and modify a pulled GENBANK file from PubMed's
#		  FTP Server and if wanted, email the information to the user.

use strict;
use warnings;
use LWP::Simple;
use CGI;
use Shell;

sub slurp($);
sub printPut();

#CREATE CGI FOR FORM SCRAPING
my $cgi = new CGI;

#CREATE SHELL FOR EMAILING
my $sh = Shell->new;

#FETCH SELECTED VIRUS
my $virus = $cgi->param('viruses');

#CHOOSE TITLE USING REGEX
my $webTitle;
if($virus){
	$webTitle = 'Zaire ebola virus [accn] NC_002549' if ($virus =~m/Zai/);
	$webTitle = 'Human respiratory syncytial virus [accn] NC_001781' if ($virus =~m/Hum/);
	$webTitle = 'African green monkey polyomavirus [accn] NC_004763' if ($virus =~m/Afr/);
	$webTitle = 'Staphylococcus aureus phage [accn] NC_004679' if ($virus =~m/Sta/);
	$webTitle = 'Yersinia pestis phage [accn] NC_004777' if ($virus =~m/Yer/);
}
##START PRINTING##
print "Content-type: text/html\n\n";
print "<html><head>";
print "<title>$webTitle</title>";
print "</head>";
print "<body>";
print "<pre>";
##################

#FETCH EMAIL ADDRESS
my $email = $cgi->param('mailto');


#WAS ANYTHING ENTERED INTO EMAIL TEXTBOX?
if ($email){
	#UNLESS EMAIL IS CORRECT -> KILL PROGRAM
	unless ($email =~ m/.*@.*\..*./){ 
		print "You didn't put in a correctly formatted email address! </body></html>";
		exit
	}
}

#CREATE AND OPEN EMAIL ATTACHMENT
my $attachment = "NCBI.dat";
open (attach, "> $attachment") or die("Error Opening Attachment File: $!\n");


#CREATE STANDARD URL TEMPLATE
my $url = "ftp://ftp.ncbi.nih.gov/genomes/Viruses/";

#APPEND SELECTED VIRUS TO URL
$url .= $virus;

#CREATE TEMP FILE FOR URL STORAGE
my $temp = "temp.tmp";

#DOWNLOAD URL INTO TEMPFILE
getstore($url, $temp);

#SLURP TEMP FILE
my $slurpped = slurp($temp);

#SPLIT SLURPPED CONTENTS INTO ARRAY FOR PRINTING
my @lines = split('\n', $slurpped);

#CREATE A PRINTING SWITCH -> CONTROL WITH 0 = OFF, 1 = ON
my $maybePrint;

#LOCUS
my $locus = $cgi->param('LOCUS');
if ($locus){
	foreach (@lines){
		$maybePrint = 1 if ($_ =~ m/LOCUS/);
		$maybePrint = 0 if ($_ =~ m/DEFINITION/);
		printPut;
	}
}

#DEFINITION
my $definition = $cgi->param('DEFINITION');
if ($definition){
	foreach (@lines){
		$maybePrint = 1 if ($_ =~ m/DEFINITION/);
		$maybePrint = 0 if ($_ =~ m/ACCESSION/);
		printPut;
	}
}

#ACCESSION
my $accession = $cgi->param('ACCESSION');
if ($accession){
	foreach (@lines){
		$maybePrint = 1 if ($_ =~ m/ACCESSION/);
		$maybePrint = 0 if ($_ =~ m/VERSION/);
		printPut;
	}
}
#VERSION
my $version = $cgi->param('VERSION');
if ($version){
	foreach (@lines){
		$maybePrint = 1 if ($_ =~ m/VERSION/);
		$maybePrint = 0 if ($_ =~ m/KEYWORDS/);
		printPut;
	}
}
#KEYWORDS
my $keywords = $cgi->param('KEYWORDS');
if ($keywords){
	foreach (@lines){
		$maybePrint = 1 if ($_ =~ m/KEYWORDS/);
		$maybePrint = 0 if ($_ =~ m/SOURCE/);
		printPut;
	}
}

#SOURCE
my $source = $cgi->param('SOURCE');
if ($source){
	foreach (@lines){
		$maybePrint = 1 if ($_ =~ m/SOURCE/);
		$maybePrint = 0 if ($_ =~ m/ORGANISM/);
		printPut;
	}
}

#ORGANISM
my $organism = $cgi->param('ORGANISM');
if ($organism){
	foreach (@lines){
		$maybePrint = 1 if ($_ =~ m/ORGANISM/);
		$maybePrint = 0 if ($_ =~ m/REFERENCE/);
		printPut;
	}
}

#REFERENCE
my $reference = $cgi->param('REFERENCE');
if ($reference){
	foreach (@lines){
		$maybePrint = 1 if ($_ =~ m/REFERENCE/);
		$maybePrint = 0 if ($_ =~ m/AUTHORS/);
		$maybePrint = 0 if ($_ =~ m/CONSRTM/);
		printPut;
	}
}

#AUTHORS
my $authors = $cgi->param('AUTHORS');
if ($authors){
	foreach (@lines){
		$maybePrint = 1 if ($_ =~ m/AUTHORS/);
		$maybePrint = 0 if ($_ =~ m/TITLE/);
		printPut;
	}
}
#CONSRTM
my $conrtm = $cgi->param('CONSRTM');
if ($conrtm){
	foreach (@lines){
		$maybePrint = 1 if ($_ =~ m/CONSRTM/);
		$maybePrint = 0 if ($_ =~ m/TITLE/);
		printPut;
	}
}
#TITLE
my $title = $cgi->param('TITLE');
if ($title){
	foreach (@lines){
		$maybePrint = 1 if ($_ =~ m/TITLE/);
		$maybePrint = 0 if ($_ =~ m/JOURNAL/);
		printPut;
	}
}
#JOURNAL
my $journal = $cgi->param('JOURNAL');
if ($journal){
	foreach (@lines){
		$maybePrint = 1 if ($_ =~ m/JOURNAL/);
		$maybePrint = 0 if ($_ =~ m/PUBMED/);
		$maybePrint = 0 if ($_ =~ m/REMARK/);
		$maybePrint = 0 if ($_ =~ m/REFERENCE/);
		$maybePrint = 0 if ($_ =~ m/COMMENT/);
		printPut;
	}
}
#PUBMED
my $pubmed = $cgi->param('PUBMED');
if ($pubmed){
	foreach (@lines){
		$maybePrint = 1 if ($_ =~ m/PUBMED/);
		$maybePrint = 0 if ($_ =~ m/REFERENCE/);
		printPut;
	}
}
#REMARKS
my $remark = $cgi->param('REMARK');
if ($remark){
	foreach (@lines){
		$maybePrint = 1 if ($_ =~ m/REMARK/);
		$maybePrint = 0 if ($_ =~ m/REFERENCE/);
		printPut;
	}
}
#COMMENT
my $comment = $cgi->param('COMMENT');
if ($comment){
	foreach (@lines){
		$maybePrint = 1 if ($_ =~ m/COMMENT/);
		$maybePrint = 0 if ($_ =~ m/FEATURES/);
		printPut;
	}
}
#FEATURES
my $features = $cgi->param('FEATURES');
if ($features){
	foreach (@lines){
		$maybePrint = 1 if ($_ =~ m/FEATURES/);
		$maybePrint = 0 if ($_ =~ m/ORIGIN/);
		printPut;
	}
}
#BASECOUNT
my $bases = $cgi->param('BASECOUNT');
if ($bases){
	my ($cCount, $aCount, $tCount, $gCount, @pushIt, @fasta, $scalePush, $maybePush);
	#PUSH GENOME SEQUENCE INTO ARRAY CALLED FASTA
	foreach(@lines){
		$maybePush = 1 if ($_=~m/ORIGIN/);
		$maybePush = 0 if ($_=~m/\/\//);
		if ($maybePush == 1){
			push(@fasta, $_);
		}
	}
	#COUNT THE CHARACTERS WITH REGEX AND PUSH COUNT PER LINE INTO @PUSHIT
	#CONVERT COUNT INTO SCALAR AND PUSH INTO SPECIFIC COUNT VARIABLE
	foreach(@fasta){
		@pushIt = ($_ =~ /a/g);
		$scalePush = (scalar @pushIt);
		$aCount = $aCount + $scalePush;
		
		@pushIt = ($_ =~ /c/g);
		$scalePush = (scalar @pushIt);
		$cCount = $cCount + $scalePush;
		
		@pushIt = ($_ =~ /t/g);
		$scalePush = (scalar @pushIt);
		$tCount = $tCount + $scalePush;
		
		@pushIt = ($_ =~ /g/g);
		$scalePush = (scalar @pushIt);
		$gCount = $gCount + $scalePush;
	}
	print "BASE COUNT      $aCount A    $cCount C    $gCount G     $tCount T\n";
	print attach "BASE COUNT      $aCount A    $cCount C    $gCount G     $tCount T\n";
}
#ORIGIN
my $origin =$cgi->param('ORIGIN');
if ($origin){
	foreach (@lines){
		$maybePrint = 1 if ($_ =~ m/ORIGIN/);
		$maybePrint = 0 if ($_ =~ m/\/\//);
		printPut;
	}
}

##END PRINTING##
close attach;
print "</pre></body></html>";
################

#EMAIL ATTACHMENT FILE CONTENTS
if($email){
	$sh->mail(qq[-s "$webTitle" $email < NCBI.dat]);
}

sub slurp($) {
    my $file = shift;
    open (FH, "< $file") or die("ERROR SLURPING FILE: $!\n");
    local $/ = undef;
    my $cont = <FH>;
    close FH;
    return $cont;
}
sub printPut(){
	if ($maybePrint == 1){
			print "$_\n";
			print attach "$_\n";
		}
}
#DELETE TEMP FILE AND ATTACHMENT FILE
unlink $temp; 
unlink $attachment;
