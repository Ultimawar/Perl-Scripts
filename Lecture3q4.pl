#Lecture 3 Q4
use strict;
use warnings;

print qq (enter a whole number: );
chomp(my $number = <STDIN>);

my $binNumb = (sprintf (qq (%b), $number)); #convert to binary

my $reverse = reverse($binNumb); #reverse binary

my $line = qq(00000000000000000000000000000000); #create template

my $repLeng = length($binNumb); #length of binary to replace on template

substr($line, 0, $repLeng, $reverse); #replace with binary

$line = reverse($line); #reverse line to correct position

for (my $i = 0; $i lt 4; $i++){
	substr($line, ($i*9), 0, qq( ));
} #This for loop adds spaces in the line. 
  #use 9 rather than 8, because each space adds another char to length
  #meaning 8 will always be 1 char too short compounding with each
  #addition

substr ($line,0,1,""); #chops insert at $i=0

print qq($line \n); #print final line
