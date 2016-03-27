#!/usr/bin/perl

# AUTHOR: KESHAV DIAL
# I declare that the attached assignment is wholly my own work in accordance with
# Seneca Academic Policy. No part of this assignment has been copied manually or
# electronically from any other source (including web sites) or distributed to other students.
# Name: Keshav Dial
# ID: 250526958
# COURSE: BIF724
# ASSIGNMENT: #1
# NAME OF PROGRAM: keshav_a1_upload.cgi
# PURPOSE: This program is the "Upload A File" perl program. This dynamically prints a file upload form and verifies the file's data before entering it into a database.

use strict;
use warnings;
use DBI;
use CGI qw/:standard/;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
require '/home/bif724_161a07/public_html/keshav_a1_lib.pl';
require '/home/bif724_161a07/.credentials';

## CONNECTING TO DATABASE ##
my $password = get_paswd();
my $dbh = DBI->connect("DBI:mysql:host=db-mysql;database=bif724_161a07", 'bif724_161a07', $password) or die("Error: Cannot connect to database".DBI->errstr);
############################
my $cgi = new CGI;
my @error_codes;

### IF A FORM HAS BEEN SUBMITTED, THEN CONTINUE ELSE PRINT THE FORM ###
if (param()) {
    ## GET THE FILE NAME ##
    my $up_file_name = param('up_file'); # Gets the filename
    my $extension = substr($up_file_name, -4); # Isolates the extension
    my $filename_pre = substr($up_file_name, 0, -4); # Isolates the file name without extension
     
    ## VERIFY THE UPLOAD FILE NAME AND EXTENSION ##
    if($up_file_name){
      unless ($filename_pre=~/^[a-zA-Z0-9_\-]*$/) {# Verify that no illegal characters in name
        push(@error_codes, "ERROR: Illegal character entered in filename! TIP: Filename limited to Alpha-numeric, with the exceptions of '-' and '_' symbols" );
        }
        unless ($extension eq ".csv"){# Verify it's the correct extension
            push(@error_codes, "ERROR: Wrong File extension! TIP: Upload a *.csv file.");
        }  
    }else{
        push(@error_codes, "Choose a file!");
    }
    
    ## CHECKPOINT #1 -> DID THE FILE NAME PASS? IF NOT PRINT ERRORS AND FORM! ##
    if (scalar @error_codes > 0){
        print starter_html();
        add_breaks(@error_codes);
        print qq~<form action="$0" method="post" enctype="multipart/form-data">~, create_errors_div(@error_codes), upload_form(), end_html();
    }else{
        ## PASSED! UPLOAD FILE! ##
        my $upfh = upload('up_file');
        my @all_lines = <$upfh>; # Storing each row of the CSV file
        my @broken_entries; # Will store entries that do not pass verification criteria
        
        foreach (@all_lines){
            @error_codes = ();# Clean stored error codes from previous loop on each iteration
            my @csv_entry = split (/,/, $_);# Split the CSV based on commas (breaks each row into columns)
            
            ## STORE EACH OF THE COLUMNS WITHIN INDIVIDUAL VARIABLES FOR VERIFICATION ##
            my $re1_id = $csv_entry[0];
            my $score = $csv_entry[1];
            my $target_gene_id = $csv_entry[2];
            my $position_re1_relative = $csv_entry[3];
            my $gene_strand = $csv_entry[4];
            my $gene_description = $csv_entry[5];
            
            ## SPLIT RE1_ID ON UNDERSCORE BEFORE PROCESSING ##
            my @split_re1 = split(/_/, $re1_id);
            
            ## VERIFY EACH OF THE COLUMNS ##
            if (re1_check(@split_re1)) {
                push(@error_codes, re1_check(@split_re1));
            }
            if (duplication_check($re1_id)) {
                push(@error_codes, duplication_check($re1_id));
            }
            if (cross_check($split_re1[0], $target_gene_id)){
                push (@error_codes, cross_check($split_re1[0], $target_gene_id));
            }
            push(@error_codes, score_check($score));
            push(@error_codes, target_gene_check($target_gene_id));
            push(@error_codes, position_check($position_re1_relative));
            push(@error_codes, orientation_check($gene_strand));
            if ($gene_description) {# If something is in the Gene Description then verify
                push(@error_codes, gene_description_check($gene_description))
           }
            
            ## CHECKPOINT #2 -> WERE THERE ANY ERRORS? IF SO, STORE THE ROW IN THE BROKEN ENTRIES ARRAY ##
            if (scalar @error_codes > 0) {
                push (@broken_entries, $_);
            }else{
                ## PASSED! PUSH THE ROW INTO THE DATABASE! ##
                my $sql_insert = "INSERT INTO a1_data values (?, ?, ?, ?, ?, ?)";
                my $sth_insert = $dbh->prepare($sql_insert) or die("problem preparing SQL insert statment");
                my $insert_execution = $sth_insert->execute($re1_id, $score, $target_gene_id, $position_re1_relative,$gene_strand,$gene_description);
            }
            
            ### DEBUGGER - WHAT ERROR TRIGGERED IN ENTRY ###
            # print @error_codes;
        }
        ## PROCESS BROKEN ENTRIES FOR HTML AND THEN PRINT IN ERRORS DIV ELEMENT
        if (scalar @broken_entries > 0) {
            print starter_html();
            #unshift(@broken_entries, "<strong>The following entries elicited errors:</strong>");
            add_breaks(@broken_entries);
            print qq~<form action="$0" method="post" enctype="multipart/form-data">~, create_errors_div("-bad_entry",@broken_entries), upload_form(), end_html();
        }else{
            ## IF NO BROKEN ENTRIES, THEN SEND USER TO VIEW PAGE
            print $cgi->redirect('http://zenit.senecac.on.ca/~bif724_161a07/cgi-bin/keshav_a1_view.cgi')
        }
    }
    
}else{
    ## FORM FRESH RELOAD ##
    print starter_html(), qq~<form action="$0" method="post" enctype="multipart/form-data">~, upload_form(), end_html();
}
