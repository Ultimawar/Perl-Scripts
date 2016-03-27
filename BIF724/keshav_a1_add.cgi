#!/usr/bin/perl

# AUTHOR: KESHAV DIAL
# I declare that the attached assignment is wholly my own work in accordance with
# Seneca Academic Policy. No part of this assignment has been copied manually or
# electronically from any other source (including web sites) or distributed to other students.
# Name: Keshav Dial
# ID: 250526958
# COURSE: BIF724
# ASSIGNMENT: #1
# NAME OF PROGRAM: keshav_a1_add.cgi
# PURPOSE: This program is the "Add A Record" perl program. This dynamically prints a web form and verifies entered data before entering it into a database.

use strict;
use warnings;
use DBI;
use CGI qw(:standard);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
require '/home/bif724_161a07/public_html/keshav_a1_lib.pl';
require '/home/bif724_161a07/.credentials';

## CONNECTING TO DATABASE ##
my $password = get_paswd();
my $dbh = DBI->connect("DBI:mysql:host=db-mysql;database=bif724_161a07", 'bif724_161a07', $password) or die("Error: Cannot connect to database".DBI->errstr);

my $cgi = new CGI;

my @error_codes; # Will store errors
my $fail_switch; # FAIL = 1, PASS = 0; To be used as an indicator of whether form entry passes verification.
my $method = 'post';
my $action = 'keshav_a1_add.cgi';
my $textfield = \&textfield;# stores CGI Method textfield in reference
my $textarea = \&textarea;# stores CGI Method textarea in reference

my %form_inputted_data=$cgi->Vars;# stores data input from form in hash

### HASH CONTAINING GENERAL INPUT NAME ROOT AND DESCRIPTION OF FIELD ###
my %form_text_fields =(
    're1_id'=>'1. Enter the re1 ID:',
    'score' => '2. Enter the score:',
    'target_gene_id' => '3. Enter the Target Gene ID:',
    'position_re1_relative' => '4. Enter the Position of the Re1 relative to the target gene:',
    'gene_description' => '6. Enter the Description of the Gene:',
    'strand_orientation' => '5. Choose the orientation of the strand');# Used to generate field names and web description

### WHEN SUBMISSION OCCURS START PROCESSING FORM ###
if ($form_inputted_data{Submit}) {
    
    ## VERIFYING 're1_id_text' INPUT ##
    my $re1_id = $form_inputted_data{re1_id_text};
    my @split_re1 = split(/_/, $re1_id);
    if (re1_check(@split_re1)) {# Don't push re1_check unless there's an error to avoid pushing blank.
        push(@error_codes, re1_check(@split_re1));
    }
    ### IS IT A DUPLICATE ##
    if (duplication_check($re1_id)) {# Don't push duplication_check unless there's an error to avoid pushing blank.
        push(@error_codes, duplication_check($re1_id));
    }
    
    ## VERIFYING 'score_id_text' INPUT ##
    my $score_text = $form_inputted_data{score_text};
    push(@error_codes, score_check($score_text));
    
    ## VERIFYING 'target_gene_id' INPUT ##
    my $target_gene_id_text = $form_inputted_data{target_gene_id_text};
    push(@error_codes, target_gene_check($target_gene_id_text));
   
    ### CROSS CHECK RE_1 SPECIES WITH TARGET GENE ID ###
    if (cross_check($split_re1[0], $target_gene_id_text)){
        push (@error_codes, cross_check($split_re1[0], $target_gene_id_text));
    }
   
    ## VERIFYING 'position_re1_relative_text' INPUT ##
    my $position_re1_relative_text = $form_inputted_data{position_re1_relative_text};
    push (@error_codes, position_check($position_re1_relative_text));
    
    ## VERIFYING 'gene_strand_radio' INPUT ##
    my $gene_strand_radio = $form_inputted_data{strand_orientation_radio};
    push (@error_codes, orientation_check($gene_strand_radio));
    
    ## IS ANYTHING ENTERED IN 'gene_description_text' ? ##
    my $gene_description_textarea = $form_inputted_data{gene_description_text};
    ## IF SO WE VERIFY INPUT ##
    if ($gene_description_textarea) {
        push(@error_codes, gene_description_check($gene_description_textarea));
    }else{# FILL WITH EMPTY DATA #
        $gene_description_textarea="";
    }
    
## TURN ON FAIL SWITCH IF WE HAVE ERRORS -> USE AS PREREQUISITE FOR SQL LAUNCH; ##
    unless ((scalar @error_codes)>0) {
        $fail_switch = 0;
        ## INSERT INTO TABLE ##
        my $sql_insert = "INSERT INTO a1_data values (?, ?, ?, ?, ?, ?)";
        my $sth_insert = $dbh->prepare($sql_insert) or die("problem preparing SQL insert statment");
        my $insert_execution = $sth_insert->execute($re1_id, $score_text, $target_gene_id_text, $position_re1_relative_text,$gene_strand_radio,$gene_description_textarea);
        print $cgi->redirect('http://zenit.senecac.on.ca/~bif724_161a07/cgi-bin/keshav_a1_view.cgi')
    }else{
        $fail_switch = 1;
        add_breaks(@error_codes);
    }
}
### END FORM PROCESSING ###

### PRINTING REQUIRED HTML INFORMATION, MENU, HEADLINE, and DESCRIPTION ###
print header(), start_html(-title=>"Add Entry to RE1 target gene data", -style=>{'src'=>'/~bif724_161a07/styles/keshav_a1.css'}), "<link href='https://fonts.googleapis.com/css?family=Open+Sans:400,600' rel='stylesheet' type='text/css'>", create_menu_ul(), h1('RE1 target gene data'), p('To add a new entry to the RE1 Target Gene Database, fill out the form below and press the submit button. Upon submission, the data will be verified. If there are any problems with the data, an error code will be displayed in a red box. Beside the error code will be a tip, hinting on how to correct the error. Note that no duplicated entries are allowed in the database in terms of the re1 ID. The description of the gene is optional. Upon successful addition of the entry into the RE1 target gene database, you will be forwarded automatically to the "View All Records" page.'), "<br>";


### BUILDING THE FORM ###
print start_form($method,$action);

### PRINTING ERRORS ###
if ($fail_switch==1) {
    print create_errors_div(@error_codes);
}

# LOOP PRINTS ALL THE FORM'S TEXTBOX INPUT FIELDS
foreach my $key (sort { $form_text_fields{$a} <=> $form_text_fields{$b} } keys %form_text_fields) {
    if ($form_text_fields{$key} =~ /[1-4]/) {
        print create_text_input($key, $textfield, $fail_switch, %form_text_fields, %form_inputted_data);
    }elsif($form_text_fields{$key} =~ /6/){# PRINT TEXTAREA FOR NULL DESCRIPTION
        print create_text_input($key, $textarea, $fail_switch, %form_text_fields, %form_inputted_data);
    }else{# PRINT RADIO BUTTONS
    print "<div class ='input' id='strand_orientation'><a>5. Choose the orientation of the strand</a><input type='radio' name='strand_orientation_radio' value='0' style='display:none'";
    if ($fail_switch==1) {
        if ($form_inputted_data{$key."_radio"}eq"0") {
            print "checked='checked'";
        }   
    }elsif ($fail_switch==0){
            unless ($form_inputted_data{Submit}){
                print "checked='checked'";
            }
    }
    print"><label><input type='radio' name='strand_orientation_radio' value='+'";
    if ($fail_switch==1) {
        if ($form_inputted_data{$key."_radio"}eq"+") {
            print "checked='checked'";
        }
    }
    print ">+</label><label><input type='radio' name='strand_orientation_radio' value='-'";
    if ($fail_switch==1) {
        if ($form_inputted_data{$key."_radio"}eq"-") {
            print "checked='checked'";
        }
    }
    print ">-</label></div>"
    }
}

# PRINTS SUBMISSION AND RESET BUTTONS
print div({id=>'buttons'}, submit(-name=>'Submit', -value=>'Submit')), end_form, "<div class='link_back'><br><a href='keshav_a1_view.cgi'><img src='/~bif724_161a07/images/database.ico'></a><br><a class='link_back' href='keshav_a1_view.cgi'>Visit the view page</a></div>", end_html;
### END BUILDING THE FORM ###


####IMAGE CREDITS###
#Icons made by Freepik from http://www.flaticon.com; www.flaticon.com is licensed by "Creative Commons BY 3.0"
####################
