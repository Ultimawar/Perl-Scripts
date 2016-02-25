sub cleaveAndBind($$$$);

use strict;
use warnings;

my (@dna1, @dna2, $seq, $pos, $i, $ok);
$dna1[0][0] = "5p-sequence-PPPPPP-GAATTC-QQQQQQ-sequence-3p";
$dna1[1][0] = "3p-sequence-QQQQQQ-CTTAAG-PPPPPP-sequence-5p";

$dna2[0][0] = "5p-sequence-XXXXXX-GAATTC-YYYYYY-sequence-3p";
$dna2[1][0] = "3p-sequence-YYYYYY-CTTAAG-XXXXXX-sequence-5p";

$seq = "GAATTC";
$pos = 1;

$ok = cleaveAndBind(\@dna1, \@dna2, \$seq, \$pos);
print $dna1[0][0], "\n", $dna1[1][0], "\n", $dna2[0][0], "\n", $dna2[1][0], "\n" if($ok);
exit;

$seq = "GAACTT";
$ok = cleaveAndBind(\@dna1, \@dna2, \$seq, \$pos);
print $dna1[0][0], "\n", $dna1[1][0], "\n", $dna2[0][0], "\n", $dna2[1][0], "\n" if($ok);

exit;

sub cleaveAndBind($$$$) {
	#those are references to arrays and scalars
	my $refDNA1 = shift;
	my $refDNA2 = shift;
	my $refSeq = shift;
	my $refPos = shift;
	my $reverseSeq = reverse($$refSeq);
	my $length = length(${$refDNA1}[0][0]);
	my @temp1;
	my @temp2;
	#find the index number of the restriction enzyme sequence within
	
	#the first DNA strand in DNA 1
	my $offset1 = index(${$refDNA1}[0][0], $$refSeq);
	
	#if not found return false value
	unless ($offset1){
		return 0
	}
	
	my $substring1 = substr ${$refDNA1}[0][0], 0, ($offset1+1);
	my $substring2 = substr ${$refDNA1}[0][0], ($offset1+1);
	${$refDNA1}[0][0] = $substring1;
	${$refDNA1}[0][1] = $substring2;

	#the second DNA strand in DNA 1
	my $offset2 = index(${$refDNA1}[1][0], $reverseSeq);
	$substring1 = substr ${$refDNA1}[1][0], 0, -($offset2+1);
	$substring2 = substr ${$refDNA1}[1][0], -($offset2+1);
	${$refDNA1}[1][0] = $substring1;
	${$refDNA1}[1][1] = $substring2;

	#the first DNA strand in DNA 2
	$offset1 = index(${$refDNA2}[0][0], $$refSeq);
	$substring1 = substr ${$refDNA2}[0][0], 0, ($offset1+1);
	$substring2 = substr ${$refDNA2}[0][0], ($offset1+1);
	${$refDNA2}[0][0] = $substring1;
	${$refDNA2}[0][1] = $substring2;


	#the second DNA strand in DNA 2
	$offset2 = index(${$refDNA2}[1][0], $reverseSeq);
	$substring1 = substr ${$refDNA2}[1][0], 0, -($offset2+1);
	$substring2 = substr ${$refDNA2}[1][0], -($offset2+1);
	${$refDNA2}[1][0] = $substring1;
	${$refDNA2}[1][1] = $substring2;

	

	$temp1[0][0] = (${$refDNA1}[0][0] . ${$refDNA2}[0][1]); 
	$temp1[1][0] = (${$refDNA1}[1][0] . ${$refDNA2}[1][1]);
	$temp2[0][0] = (${$refDNA2}[0][0] . ${$refDNA1}[0][1]);
	$temp2[1][0] = (${$refDNA2}[1][0] . ${$refDNA1}[1][1]);

	@{$refDNA1} = @temp1;
	@{$refDNA2} = @temp2;
}


