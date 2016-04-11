# Program name: 	keshav_a2.pl
# Course:		BIF724
# Purpose: 		The purpose of this program is to allow a user to easily retrieve 
#			both the DNA sequence and translated amino acid sequence of a gene
#			of interest for a list of GenBank ids. 
# 			This program accepts 2 arguments: the first corresponding to a list
# 			which will contain the GenBank ids, the second which indicates the 
# 			gene of interest. 
#			The program outputs two files: 
#			(1)dna_keshav_*gene id*.fa and (2) aa_keshav_*gene id*.fa
#			Both will contain the DNA and AA information respectively retrieved 
#			from GenBank.

# I declare that the attached assignment is wholly my own work in accordance with
# Seneca Academic Policy. No part of this assignment has been copied manually or
# electronically from any other source (including web sites) or distributed to other students. 
# Name: Keshav Dial
# ID: 250526958

use strict;
use warnings;
use Bio::Seq;
use Bio::SeqIO;
use Bio::Species;
use Bio::DB::GenBank;
use Bio::SeqFeatureI;
use Term::ANSIColor; # Used to give error text output a red color.
use Cwd 'abs_path'; # Used to retrieve the absolute path of outputted files.

my $gb = Bio::DB::GenBank->new();

my $genbank_list = $ARGV[0];
my $gene_name = $ARGV[1];

# Generates a randomly coloured ASCII art title
my @color_list = qw /cyan bright_green yellow red blue magenta bright_red bright_green bright_yellow bright_blue bright_magenta bright_cyan/;
my $random_color = $color_list[int(rand(12))];
print color($random_color);
print <<TITLE;

********************************************
______ _____ ___________ ___________ _     
| ___ \\_   _|  _  | ___ \\  ___| ___ \\ |    
| |_/ / | | | | | | |_/ / |__ | |_/ / |    
| ___ \\ | | | | | |  __/|  __||    /| |    
| |_/ /_| |_\\ \\_/ / |   | |___| |\\ \\| |____
\\____/ \\___/ \\___/\\_|   \\____/\\_| \\_\\_____/

*******************************************

TITLE
print color('reset');


## FIRST: Check if correct number of arguments have been added. If not print ERROR statment. ##
unless ($genbank_list && $gene_name) {
	print colored(['bold red'], 'You entered ', scalar(@ARGV), ' argument', scalar(@ARGV) == 0 ? 's':'', ".\nTwo arguments are required.\nThe first should indicate your file of GenBank IDs.\nThe second should refer to your gene of interest\n");
}else{
	print colored(['bold green'],'You entered ', scalar(@ARGV), " arguments.\nYour filename is $genbank_list.\nYour gene of interest is $gene_name\n");

	## SECOND: Create Required Files ##
	my $dna_file = Bio::SeqIO->new(-file => ">dna_keshav_$gene_name.fa", -format =>"fasta");
	my $protein_file = Bio::SeqIO->new(-file =>">aa_keshav_$gene_name.fa", -format =>"fasta");

	## THIRD: Read in List and Process ##
	open(DATA, "<$genbank_list") or die(colored(['bold red'],"The file \"$genbank_list\" could not be read"),"\n");
	my @all_lines = <DATA>;
	close DATA;
	chomp @all_lines;
	
	foreach my $id (@all_lines){
		# Retrieve the Bio::Seq objects
		my $seq = $gb->get_Seq_by_id($id);
		
		# Pull the Bio:Species objects out of the Bio::Seq object
		my $species = $seq->species();

		# Pull the Binomial Species Name out of the Bio:Species object
		my $species_name = $species->binomial('FULL');
		
		# Clean the name
		$species_name =~ s/ /_/g;

		foreach my $feature ($seq->get_SeqFeatures()){

			# Search each feature for the CDS tag
			if ($feature->primary_tag eq 'CDS'){
			
				# Check CDS feature for a gene tag
				if ($feature->has_tag('gene')){

					# Retrieve the gene tag's value
					my @gene_ids = $feature->get_tag_values('gene');
			
					# Does the value match the user specified value?
					if ($gene_ids[0] eq $gene_name){

						#Print Status of Writing Amino Acid Sequence to File
						print colored(['yellow'],"Writing the $gene_name translated amino acid sequence of $id to aa_keshav_$gene_name.fa\n");
						# Write the protein sequence to the aa_keshav_gene.fa file
						my @translated = $feature->get_tag_values('translation');
						my $protein_output = Bio::Seq->new(-id => $species_name, -seq => $translated[0]);
						$protein_file->write_seq($protein_output);	

						# Retrieve start and stop positions for the gene of interest
						my $start = $feature->start();
						my $stop = $feature->end();

						# Retrieve strand orientation
						my $strand = $feature->strand();
						my $sequence_string;
						
						# Use the start and stop positions to find gene's sequence
						unless ($strand == -1){
							$sequence_string = $seq->subseq($start,$stop);
						}else{
							# If strand is -1, we need the reverse complement strand
							my $ass = Bio::Seq->new(-seq=> $seq->subseq($start,$stop));
							my $reverse = $ass->revcom();
							$sequence_string = $reverse->subseq($start,$stop);
						}
						# Print Status of Writing DNA sequence to File
						print colored(['yellow'],"Writing the $gene_name DNA sequence of $id to dna_keshav_$gene_name.fa\n");
						my $dna_output = Bio::Seq->new(-id => $species_name, -seq => $sequence_string);
						$dna_file->write_seq($dna_output);
					}
				}
			}
		}
	}
	# Finds the absolute path of where the perl script file is located and removes the name of the file, saving only the directory
	my $fh = $0;
	my $path = abs_path($0);
	$path =~ s/$fh//g;
	print colored(['bold green'], "File writing completed.\nThe DNA sequences correlating to $gene_name are stored in $path","dna_keshav_$gene_name.fa\nThe amino acid sequences correlating to $gene_name are stored in $path","aa_keshav_$gene_name.fa\n")
}

# ASCII ART GENERATOR SOURCE: patorjk.com/software/taag/
