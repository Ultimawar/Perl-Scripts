use strict;
use warnings;
use feature 'say';

sub isPrime($);

print qq[Enter a positive number that is greater than or equal 2:];
chomp(my $input = <STDIN>);

if ($input >= 2){
	say isPrime($input);
}

else {
	say qq[Invalid input];
}
sub isPrime($) {
	my $test = 0;#Sets up the count for a Prime Number Remainder Test
	for (my $i=2; $i<12; $i++){ #Loops through minimal divisable numbers
		if ($i != $input){#Make sure we aren't dividing by ourselves
			if (($input % $i) == 0){#Check if there is a remainder
				$test++;#If there is not, and not dividing by self add to count
			} #instead of doing count, could also break loop and return "Not a Prime number"
		}
	}
	if ($test>0){ #if not a prime number then $test will have filled up. aka greater than one.
		return "Not a Prime Number";
		}
	else{
		return "That number is prime as hell!";
		}
}
