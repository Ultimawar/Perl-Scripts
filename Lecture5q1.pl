#Lec5q1.pl

use strict;
use warnings;

print qq(Enter the number of rows: );
chomp(my $rows = <STDIN>);
$rows = sqrt((int($rows))**2); #removes negative and makes whole interger
my $spacing = $rows - 1;

for (my $i = 0; $i<$rows; $i++){
	#first find padding
	my $indent = ' ' x $spacing;

	#second length of line
	my $length = ($i*2 + 1);

	#third make line with variable
	my $temp = '*' x $length;

	#finally print line
	print qq($indent$temp\n);

	#reduce padding
	$spacing--;
}
