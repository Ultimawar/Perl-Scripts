#Lec5q2.pl

use strict;
use warnings;

print qq(Enter the number of rows between 1 and 9: );
chomp(my $rows = <STDIN>);
#$rows = sqrt((int($rows))**2); #removes negative and makes whole interger
my $spacing = $rows - 1;

unless ($rows < 1 || $rows > 9){
	for (my $i = 0; $i<$rows; $i++){
	#first print padding
		my $indent = ' ' x $spacing;
		my $length = ($i*2 + 1);
		my $last = (($i+1) x $length);

		print qq($indent$last\n);
		$spacing--;
	}	
}
else {
	print qq {out of bounds\n};
}
