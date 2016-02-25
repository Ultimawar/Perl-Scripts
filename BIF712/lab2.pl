use strict;
use warnings;

my $homo = <<"_END_";
		1 acatttgctt ctgacacaac tgtgttcact agcaacctca aacagacacc atggtgcatc
       61 tgactcctga ggagaagtct gccgttactg ccctgtgggg caaggtgaac gtggatgaag
      121 ttggtggtga ggccctgggc aggctgctgg tggtctaccc ttggacccag aggttctttg
      181 agtcctttgg ggatctgtcc actcctgatg ctgttatggg caaccctaag gtgaaggctc
      241 atggcaagaa agtgctcggt gcctttagtg atggcctggc tcacctggac aacctcaagg
      301 gcacctttgc cacactgagt gagctgcact gtgacaagct gcacgtggat cctgagaact
      361 tcaggctcct gggcaacgtg ctggtctgtg tgctggccca tcactttggc aaagaattca
      421 ccccaccagt gcaggctgcc tatcagaaag tggtggctgg tgtggctaat gccctggccc
      481 acaagtatca ctaagctcgc tttcttgctg tccaatttct attaaaggtt cctttgttcc
      541 ctaagtccaa ctactaaact gggggatatt atgaagggcc ttgagcatct ggattctgcc
      601 taataaaaaa catttatttt cattgc
_END_

my $maca = <<"_END_";
		1 acacttgctt ctgacacaac tgtgttcacg agcaacctca aacagacacc atggtgcatc
       61 tgactcctga ggagaagaat gccgtcacca ccctgtgggg caaggtgaac gtggatgaag
      121 ttggtggtga ggccctgggc aggctgctgg tggtctaccc ttggacccag aggttctttg
      181 agtcctttgg ggatctgtcc tctcctgatg ctgttatggg caaccctaag gtgaaggctc
      241 atggcaagaa agtgcttggt gcctttagtg atggcctgaa tcacctggac aacctcaagg
      301 gtacctttgc ccagctcagt gagctgcact gtgacaagct gcatgtggat cctgagaact
      361 tcaagctcct gggcaacgtg ctggtgtgtg tgctggccca tcactttggc aaagaattca
      421 ccccgcaagt gcaggctgcc tatcagaaag tggtggctgg tgtggctaat gccctggccc
      481 acaagtacca ctaagctcac tttcttgctg tccaatttct accaaaggtt cctttgttcc
      541 caaagtccaa ctactgaact gggggatatt atgaagggcc ttgaggatct ggattctgcc
      601 taat
_END_

#clean Homo Data
my @originalHomo = ($homo =~/[actg]/g);
my $joinedHomo = join('', @originalHomo);
my $translatedHomo = ($joinedHomo =~ tr/actg/ugac/r);
my @cleanedHomo = split //, (uc($translatedHomo));

#clean Maca Data
my @originalMaca = ($maca =~/[actg]/g);
my $joinedMaca = join('', @originalMaca);
my $translatedMaca = ($joinedMaca =~ tr/actg/ugac/r);
my @cleanedMaca = split //, (uc($translatedMaca));

my %amino = 
   ( AAA=>"K", AAG=>"K",
     GAA=>"E", GAG=>"E",
     AAC=>"N", AAU=>"N",
     GAC=>"D", GAU=>"D",
     ACA=>"T", ACC=>"T", ACG=>"T", ACU=>"T", 
     GCA=>"A", GCC=>"A", GCG=>"A", GCU=>"A",
     GGA=>"G", GGC=>"G", GGG=>"G", GGU=>"G",
     GUA=>"V", GUC=>"V", GUG=>"V", GUU=>"V",
     AUG=>"M",
     UAA=>"*", UAG=>"*", UGA=>"*",
     AUC=>"I", AUU=>"I", AUA=>"I",
     UAC=>"Y", UAU=>"Y",
     CAA=>"Q", CAG=>"Q",
     AGC=>"S", AGU=>"S",
     UCA=>"S", UCC=>"S", UCG=>"S", UCU=>"S",
     CAC=>"H", CAU=>"H",
     UGC=>"C", UGU=>"C",
     CCA=>"P", CCC=>"P", CCG=>"P", CCU=>"P",
     UGG=>"W",
     AGA=>"R", AGG=>"R",
     CGA=>"R", CGC=>"R", CGG=>"R", CGU=>"R",
     UUA=>"L", UUG=>"L", CUA=>"L", CUC=>"L", CUG=>"L", CUU=>"L",
     UUC=>"F", UUU=>"F"
   );

#sort Homo into triplets
my $homoCount = scalar @cleanedHomo;
my $popper = $homoCount %3;
if ($popper){
	for (my $i=0; $i<$popper; $i++){
		pop(@cleanedHomo);
	}
}
my $tripletHomoCount = $homoCount/3;
my @homoTriplets;
for (my $j=0; $j<$tripletHomoCount; $j++){
	my @tempSplicer = splice(@cleanedHomo, 0,3);
	my $joiner = join('', @tempSplicer);
	push @homoTriplets, $joiner;
}

#sort Maca into triplets
my $macaCount = scalar @cleanedMaca;
my $popperTwo = $macaCount %3;
if ($popperTwo){
	for (my $k=0; $k<$popperTwo; $k++){
		pop(@cleanedMaca);
	}
}
my $tripletMacaCount = $macaCount/3;
my @macaTriplets;
for (my $l=0; $l<$tripletMacaCount; $l++){
	my @tempSplicerTwo = splice(@cleanedMaca, 0,3);
	my $joinerTwo = join('', @tempSplicerTwo);
	push @macaTriplets, $joinerTwo;
}

#remove undefined last entries
pop(@homoTriplets);
pop(@macaTriplets);

#translate into proteins
my @homoAmino;
foreach (@homoTriplets){
	push @homoAmino, $amino{$_};
}
my @macaAmino;
foreach(@macaTriplets){
	push @macaAmino, $amino{$_};
}

#make X Axis
my $xAxis = join('', @homoAmino);
print " $xAxis\n";

#prints Dot Plot
my $count = scalar(@macaAmino);
for (my $m=0; $m<$count; $m++){
	my $spacer = " " x $m;
	if ($homoAmino[$m] eq $macaAmino[$m]){
		my $positive = 'X';
		print "$macaAmino[$m]$spacer$positive\n";
	}
	else {
		print"$macaAmino[$m]$spacer \n";
	}
}

#calculate length of both DNA sequences.
my $homoLength = scalar(@originalHomo);
my $macaLength = scalar(@originalMaca);
my $percentage;

if ($homoLength < $macaLength){
	my $comparison = 0;
	for (my $n=0; $n<$homoLength; $n++){
		if ($originalHomo[$n] eq $originalMaca[$n]){
			$comparison++;
		}
	}
	$percentage = sprintf("%.4f",($comparison*100/$homoLength));
}
else{
	my $comparison = 0;
	for (my $n=0; $n<$macaLength; $n++){
		if ($originalHomo[$n] eq $originalMaca[$n]){
			$comparison++;
		}
	}
	$percentage = sprintf("%.4f",($comparison*100/$homoLength));
}
print"percent identity: $percentage%\n";
