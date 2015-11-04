use strict;
use warnings;

my ($pi, $i);
my @piSum =();
print "Enter how many times this loop should be executed: \n";
chomp (my $loopNum = <STDIN>);

for ($i = 0; $i<$loopNum; $i++){
	if (($i % 2) == 0){
		push @piSum, (4/((2*$i)+1));
	}
	else{
		push @piSum, (-4/((2*$i)+1));
	}
}
my $sum = eval join '+', @piSum;
printf "Pi has been calculated to: %.10f\n", $sum;
