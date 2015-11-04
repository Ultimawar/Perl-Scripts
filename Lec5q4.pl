use strict;
use warnings;
use feature qw(say); #allows say command (println)

my %dictionary = ('A' => "Adenine", 'T' => "Thymine", 'C' => "Cytosine",
				  'G' => "Guanine", 'U' => "Uracil");

say keys(%dictionary);

say values(%dictionary);

print qq{Enter a nucleotide symbol brah:};
chomp(my $newKey = uc(<STDIN>));

if ($dictionary{$newKey}){
	say qq[Value is : "$dictionary{$newKey}"]; 
}

unless ($dictionary{$newKey}){ #could also use else statement
	say "Could not find the value brah. I am le sad.";
}
