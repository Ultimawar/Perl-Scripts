#Lec5q3.pl

use strict;
use warnings;

print qq(Enter the number of rows between 1 and 9: );
chomp(my $rows = <STDIN>);
my $spacing = $rows - 1;

unless ($rows < 1 || $rows > 9){
	for (my $i = 0; $i<$rows; $i++){
		#first find padding
		my $indent = ' ' x $spacing;

		#find length of half triangle
		my $length = ($i-1); #triangle at $i=2 aka row 3, only has value from index 0 to 1.
		
		#find sequence of half triangle
		my $initial = 0;
		my @range = ($initial..$length); #will create range from 0 to length inclusive. If length is negative (ex. $i=0), no triangle.
		my $line = join('', @range);
		
		#Finally print it!
		print qq($indent$line); #print padding, print half a triangle
		print qq($i); #print middle $i value (because middle value is row# -1)
		my $reverseLine = reverse($line); #create reverse triangle
		print qq($reverseLine); #print reverse trinagle
		print qq(\n); #line break
		$spacing--;
	}	
}
else {
	print qq {out of bounds\n};
}
