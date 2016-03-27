#!/usr/bin/perl

# AUTHOR: KESHAV DIAL
# I declare that the attached assignment is wholly my own work in accordance with
# Seneca Academic Policy. No part of this assignment has been copied manually or
# electronically from any other source (including web sites) or distributed to other students.
# Name: Keshav Dial
# ID: 250526958
# COURSE: BIF724
# ASSIGNMENT: #1
# NAME OF PROGRAM: keshav_a1_view.cgi
# PURPOSE: This program is the "View All Records" perl program. This dynamically prints a database's table. It links gene id's to the corresponding ENSEMBL pages and allows data sorting via attributes.

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
############################

my $cgi = new CGI;
my $sql_sort = $cgi->param('sql_sort');

### IF NO SORTING PARAMETER IS SELECTED, SET TO SORT PARAMETER TO NULL ###
unless ($sql_sort) {
    $sql_sort = "null";
}

### FETCH ROWS FROM SQL SERVER AND SORT ACCORDING TO SELECTION/LACK THERE OF ###
my $sql = "SELECT * FROM a1_data ORDER BY ?";
my $sth = $dbh->prepare($sql) or die("Problems preparing SQL");
my $success = $sth->execute($sql_sort) or die("Problems executing SQL");

### PRINTING REQUIRED HTML INFORMATION, MENU, HEADLINE, AND DESCRIPTION ###
print header(), start_html(-title=>"View Entries of RE1 target gene data", -style=>{'src'=>'/~bif724_161a07/styles/keshav_a1.css'}), "<link href='https://fonts.googleapis.com/css?family=Open+Sans:400,600' rel='stylesheet' type='text/css'>", create_menu_ul(), h1('RE1 target gene data'), p("The Re1 target gene database table is shown below. By clicking on any of the six table headers, you can sort the table's row by that attribute. The selected attribute will become bolded and a down arrow symbol will appear beside the selected table header. You can also view the Gene ID's ENSEMBL page by clicking on the Gene ID link. Click either on the menu link, or the link at the bottom of the page to return to the \"Add a Record\" page."), "<br>";

### PRINTING TABLE ###
# If the SQL successfully returned a row, continue to print rows otherwise print "No records found"
if ($success != 0) {
    #If a column has been selected, then print a success box on top of table displaying which attribute the table is sorted by.  
    if ($sql_sort ne "null") {
        print div({-id=>'sortby', -class=>'success'}, a("Sorted Request by $sql_sort")), '<br>';
    }
    #Uses Ternary Operator bold column name if selected to sort by and includes arrow down symbol
      print
      "<table class='center' id='Database_Table'><tbody><tr><th><a href='keshav_a1_view.cgi?sql_sort=re1_id'",
      $sql_sort eq 're1_id'? "style='font-weight: 900;'>Re1 ID &#9660":'>Re1 ID',
      "</a></th><th><a href='keshav_a1_view.cgi?sql_sort=score'",
      $sql_sort eq 'score'? "style='font-weight: 900;'>Score &#9660":'>Score',
      "</a></th><th><a href='keshav_a1_view.cgi?sql_sort=gene_id'",
      $sql_sort eq 'gene_id'? "style='font-weight: 900;'>Gene ID &#9660":'>Gene ID',
      "</a></th><th><a href='keshav_a1_view.cgi?sql_sort=re1_rel_pos'",
      $sql_sort eq 're1_rel_pos'? "style='font-weight: 900;'>Re1 Relative Position &#9660":'>Re1 Relative Position',
      "</a></th><th><a href='keshav_a1_view.cgi?sql_sort=gene_strand'",
      $sql_sort eq 'gene_strand'? "style='font-weight: 900;'>Gene Strand Orientation &#9660":'>Gene Strand Orientation',
      "</a></th><th><a href='keshav_a1_view.cgi?sql_sort=description'",
      $sql_sort eq 'description'? "style='font-weight: 900;'>Description &#9660":'>Description',"</a></th>";
    # Prints the remaining table data  
    while(my @row = $sth->fetchrow_array){
        print "<tr><td>$row[0]</td><td>$row[1]</td><td><a target='_blank' href=http://uswest.ensembl.org/Gene/Summary?db=core;g=$row[2]>$row[2]</a></td><td>$row[3]</td><td>$row[4]</td><td>$row[5]</td>";
    }
} else {
    print "no records found\n";
}
print "</tbody></table>";
### END TABLE PRINTING ###

### PRINT LINK TO ADD PAGE ###
print "<div class='link_back'><br><a href='keshav_a1_add.cgi'><img src='/~bif724_161a07/images/add-icon.png'></a><br><a class='link_back' href='keshav_a1_add.cgi'>Visit the add page</a></div>", end_html();

####IMAGE CREDITS###
#Icons made by Freepik from http://www.flaticon.com; www.flaticon.com is licensed by "Creative Commons BY 3.0"
####################
