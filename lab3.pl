use strict;
use warnings;

my $s1 = "ACTGATTCA";
my $s2 = "ACGCATCA";
my $l1 = (length($s1)) + 1;
my $l2 = (length($s2)) + 1;
my $gapPen= -2;
my $match = 1;
my $mismatch = -1;
my @split1 = split('', $s1);
my @split2 = split('', $s2);
my $arrayRef;
########

my @matrix;
my $letter1;
my $letter2;


for (my $z = 0; $z < $l2; $z++){
	if ($z == 0){
		#fill row 0
		for (my $i = 0; $i < $l1; $i++){
			if ($i == 0){
				$matrix[$z][$i] = 0;
			}
			else{
				$matrix[$z][$i] = (($matrix[$z][($i-1)]) + $gapPen);
			}
		}
	}
		#### FINISHED FIRST ROW, NOW DO OTHERS
	else{
		for (my $j = 0; $j < $l1; $j++){
			if ($j == 0){
				$matrix[$z][$j] = (($matrix[$z-1][$j]) + $gapPen);
			}
			else{
				#first calculate three variables
				my @max;
				#first (first row + gap penalty)
				push (@max, ($matrix[$z-1][$j] + $gapPen));
				#second (previous value + gap penalty)
				push (@max, ($matrix[$z][($j-1)] + $gapPen));
				#third (match + )
				if ($split1[($j-1)] eq $split2[($z-1)]){
					push (@max, (($match + $matrix[$z-1][$j-1])));
				}
				else{
					push (@max, (($mismatch + $matrix[$z-1][$j-1])));
				}
				@max = sort { $a <=> $b } @max;
				$matrix[$z][$j] = (splice(@max, -1));
			}
		}
	}
}
my $count;
foreach $arrayRef (@matrix){
	print "@{$arrayRef}\n";
	$count++;
}
print $matrix[($l2-1)][$l1-1], "\n";
