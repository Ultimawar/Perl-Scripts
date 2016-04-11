#!/usr/bin/perl -l

# ASSIGNMENT:   3 - ENSEMBL CHICKEN GENE SEARCH
# AUTHOR:       Keshav Dial
# DESCRIPTION:  Program uses Ensembl API to search chicken chromosomes for genes and displays them using BioPerl Graphics and within a table.


# I declare that the attached assignment is wholly my own work in accordance with
# Seneca Academic Policy. No part of this assignment has been copied manually or
# electronically from any other source (including web sites) or distributed to other students.
# Name:Keshav Dial  
# ID:250526958

use warnings;
use strict;
use lib '/home/john.samuel/src/ensembl/modules';
use CGI qw(:standard);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use Bio::EnsEMBL::Registry;
use Bio::Graphics;
use Bio::SeqFeature::Generic;

my $cgi = new CGI;

my @error_codes;
my $method = 'post';
my $action = 'keshav_a3.cgi';

my %form_inputted_data=$cgi->Vars;

#SET DEFULT INFORMATION#
my $selected_chromosome = '22';
my $selected_start = '14189';
my $selected_end = '105344';
##

## INPUT VERIFICATION ##
if ($form_inputted_data{Submit}) {

    #Store Chromosome
    $selected_chromosome = $form_inputted_data{chromosome_drop};
    
    # VERIFY START
    $selected_start = $form_inputted_data{start_text};
    unless ($selected_start =~ /^\d*$/){
        push(@error_codes, "ERROR: Start position is not a number");
    }
    unless ($selected_start >= 1){
        push(@error_codes, "ERROR: Start position must be greater than or equal to 1");
    }
    ### CONNECT TO ENSEMBL ##
    my $registry = 'Bio::EnsEMBL::Registry';
    $registry->load_registry_from_db(-host => 'ensembldb.ensembl.org',-user => 'anonymous');
    my $species = "chicken";
    my $slice_adaptor = $registry->get_adaptor( $species, 'Core', 'Slice' );
    #########################
    
    ## VERIFY END
    # Retrieve END value
    my $slice = $slice_adaptor->fetch_by_region( 'chromosome', $selected_chromosome);
    my $end_maximum = $slice->end();
       
    $selected_end = $form_inputted_data{stop_text};
    unless ($selected_end =~ /^\d*$/){
        push(@error_codes, "ERROR: End position is not a number")
    }
    unless ($selected_end <= $end_maximum){
        push(@error_codes, "ERROR: End position is too big. It must be less than $end_maximum.");
    }
    
    # VERIFY START AND END DISTANCES
    unless ($selected_start < $selected_end){
        push(@error_codes, "ERROR: Start position is greater than Stop position.")
    }
    unless($selected_end-$selected_start>=1000){
        push(@error_codes, "ERROR: Start and Stop positions must be at least 1000 bp apart.")
    }
    unless($selected_end-$selected_start<=100000000){
        push(@error_codes, "ERROR: Start and Stop positions cannot be greater than 100,000,000 bp apart.")
    }
    
    if (scalar @error_codes) {
        # FAILED BECAUSE OF ERRORS, PRINT WEB FORM
        print_web_form($method, $action, \@error_codes, $selected_chromosome, $selected_end, $selected_start);
    }else{
        # PROCEED TO ENSEMBL PROCESSING
        $slice = $slice_adaptor->fetch_by_region('chromosome', $selected_chromosome, $selected_start, $selected_end);
        my @genes = @{$slice->get_all_Genes()};
        
        # PRINT RESULTS
        print header(), start_html(-title=> "Chicken Chromosome $selected_chromosome ($selected_start - $selected_end)", -style=>{'src'=>'/~bif724_161a07/styles/keshav_a1.css'});
        print "<div id='page_description'><h1>Report for region: Chicken Chromosome $selected_chromosome from $selected_start to $selected_end</h1></div>";
        unless (scalar @genes == 0) {
            print "<p>Showing All Genes</p>"
        }
        print "<table id='results_table' class='center'><tbody><tr><th>GeneID</th><th>Start</th>
            <th>End</th><th>Strand</th><th>Length</th><th>Description</th><th>External Name</th>
            <th>Gene Type</th><th>Status</th><th> No. of Transcripts</th>";
        
        # IF GENES EXIST START GENERATING IMAGE AND FILL TABLE
        
        if (scalar @genes > 0) {
            my $panel = Bio::Graphics::Panel->new(
                                                -offset    => $selected_start,
                                                -length    => ($selected_end-$selected_start),
                                                -keystyle  => 'between',
                                                -width     => 800,
                                                -pad_left  => 150,
                                                -pad_right => 150,
                                                );
            my $full_length = Bio::SeqFeature::Generic->new(
                                                            -start => $selected_start,
                                                            -end   => $selected_end,
                                                            );
            # Create the full length arrow image
            $panel->add_track(
                            $full_length,
                            -glyph   => 'arrow',
                            -tick    => 2,
                            -fgcolor => 'black',
                            -double  => 1,
                            );
            # Sets parameters for graphics of added tracks
            my $track = $panel->add_track(
                                        -glyph       => 'transcript2',
                                        -stranded    => 1,
                                        -label       => 1,
                                        -bgcolor     => 'blue',
                                        -font2color  => 'magenta',
                                        -description => sub {
                                            my $feature = shift;
                                            my $description= $feature->annotation;
                                            return "$description";
                                         },
                                        -fontcolor   => sub{
                                            my $feature = shift;
                                            my $description = $feature->annotation;
                                            my $color = 'black';
                                            if ($description eq "protein_coding") {
                                                $color = "red";
                                            }
                                            return "$color";
                                        },
                                        );
            foreach (@genes) {
                my $id = $_->stable_id();
                my $start = $_->seq_region_start();
                my $end = $_->seq_region_end();
                my $strand = $_->strand();
                # CLEAN STRAND DATA
                my $clean_strand;
                if ($strand == 1){
                    $clean_strand = "+";
                }else{
                    $clean_strand = "-";
                }
                my $length = $_->length();
                my $description = $_->description();
                my $external = $_->external_name();
                my $gene_type = $_->biotype();
                my $status = $_->status();
            
                # GET NUMBER OF TRANSCRIPTS
                my @transcripts = @{$_->get_all_Transcripts()};
                my $transcript_number = scalar @transcripts;
            
                #FILL TABLE WITH DATA
                print "<tr><td><a href=http://uswest.ensembl.org/Gene/Summary?db=core;g=$id>$id</a></td><td>$start</td><td>$end</td><td>$clean_strand</td><td>$length</td><td>$description</td><td>$external</td><td>$gene_type</td><td>$status</td><td>$transcript_number</td>";       
        
                #GENERATE IMAGE
                my $graphic_feature = Bio::SeqFeature::Generic->new(
                                                                    -display_name => "$id ($start - $end)",
                                                                    -start => $start,
                                                                    -strand => $strand,
                                                                    -end => $end,
                                                                    -annotation => $gene_type,
                                                                    );
                $track->add_feature($graphic_feature);
            }
            open(my $out, '>', '../images/graphic.png') or die "Could not create graphic";
            binmode $out;
            print $out $panel->png;
            print "</table><br><br><div class='link_back2'><img src='/~bif724_161a07/images/graphic.png' alt='graphic for Chicken Chromosome $selected_chromosome from $selected_start to $selected_end'></div>";
        }else{
            print "<tr><td colspan='10'>no genes found</td></table><br>"
        }
        print "<br><div class='center'><a href='keshav_a3.cgi'>new search</a></div>";
    }
}else{
    # ON LOAD PRINT WEB FORM
    print_web_form($method, $action, \@error_codes, $selected_chromosome, $selected_end, $selected_start);
}

## SUBROUTINES ##

sub print_web_form(){
    my $method_sub = @_[0];
    my $action_sub = @_[1];
    my @error_codes_sub = @{$_[2]};
    my $selected_chromosome_sub = @_[3];
    my $selected_end_sub = @_[4];
    my $selected_start_sub = @_[5];
    
    print header(), start_html(-title=>"Chicken EnSEMBL Gene Information Form", -style=>{'src'=>'/~bif724_161a07/styles/keshav_a1.css'});
    
    print <<DESCRIPTION;
    <h1>Chicken Ensembl</h1>
    <p> This page is used for searching the species 'chicken' also known as
    'Gallus gallus' for genes. This page is uses the database source ensembl.</p>
    <p> To use this page, choose your chicken chromosome of interest.
    Then specify your search interval using the start and stop points on the chromosome that you wish to
    search for genes. Your start position must be greater than one but less than
    your ending position. Your ending position cannot be larger than the length of the
    chromosome. The distance between your start and stop positions must be
    greater than 1e3 but not greater than 10e7. Only intergers are allowed in the start
    and stop text boxes. Upon form completion, press the submit button.</p>
    
    <p>If any genes are found, they will be displayed in a table on
    the following page. This will be accompanied by a graphic below the table. If
    no genes are found, no graphic will be displayed. The table's contents will say
    "no genes found".
    </p>
    <br>
    <h4>Examples</h4>
    <h5>Chromosome 22 - 5 Genes</h5>
    <p>
    Try the default settings. <span style='font-style: italic;'>Chromosome 22, Start: 14189, Stop: 105344</span>. <br>You will find
    five genes: ENSGALG00000000014, ENSGALG00000000019, ENSGALG00000027386, ENSGALG00000025953 and 
    ENSGALG00000000033.
    </p><br>
    <h5>Chromosome 13 - 3 Genes</h5>
    <p>
    Try these settings to find 3 genes: <span style='font-style: italic;'>Chromosome 13, Start:
    75000 and Stop: 100300</span>. <br>This will let you find ENSGALG00000005427, ENSGALG00000026141
     and ENSGALG00000028320.
    </p><br>
    <h5>Chromosome MT - 4 Genes</h5>
    <p>
    Try these settings to find 4 genes: <span style='font-style: italic;'>Chromosome MT, Start:
    4045 and Stop: 5240</span><br> This will let you find ENSGALG00000018382, ENSGALG00000018381,
    ENSGALG00000018380 and ENSGALG00000018379.
    </p><br>
    <h5>Chromosome 1 - 0 Genes</h5>
    <p>
    If you do not want results, try these results: <span style='font-style: italic;'>Chromosome 1, Start:
    16500, End: 30000</span><br>You will find zero genes using this setting.
    </p><br>
    
DESCRIPTION
    
    print start_form($method_sub,$action_sub);

    if (scalar @error_codes_sub > 0) {
        print "<div id='errors' class='warnings'>";
        foreach (@error_codes_sub){
            print "$_ <br>";
        }
        print "</div>";
    }

    print qq~<div id="chromosome"><a>Selected Chromosome: </a>~,
        popup_menu('chromosome_drop',
	    ['1','2','3','4', '5', '6', '7', '8','9','10',
        '11','12','13','14','15','16','17','18','19',
        '20','21','22','23','24','26','27','28','32',
        'w', 'z', 'LGE22C19W28_E50C23', 'LGE64', 'MT'],
        $selected_chromosome_sub), qq~</div>\n~;
    print qq~<div id="start"><a>Start Position: </a>~,
        textfield('start_text', $selected_start_sub), "</div>\n";
    print qq~<div id="stop"><a>Stop Position: </a>~,
        textfield('stop_text', $selected_end_sub), "</div>\n";
    print qq~<div id="button">~,
        submit(-name=>'Submit', -value=>'Submit'), "</div></form>";
    
    print end_html;
}
