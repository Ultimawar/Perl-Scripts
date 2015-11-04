use strict;
use warnings;
use feature qw(say); #allows say command (println)

my %dictionary;

print qq{Enter a word:}; 
chomp(my $newKey = uc(<STDIN>)); 	   #takes an initial input


while ($newKey ne 'EXIT'){ 			   #as long as the user doesn't enter exit, look up the key
	if (exists($dictionary{$newKey})){ #check if the definition exists
		say qq[I already know what that means]; 
	}

	else{ 
		print "Enter a defintion:";	   
		chomp(my $newDef = <STDIN>);	
		$dictionary{$newKey} = $newDef; #creates a new value for that key
	}
	say qq[$newKey --> $dictionary{$newKey}];	#says the definition
	print qq{Type Exit to Quit or Enter another word:};
	chomp($newKey = uc(<STDIN>)); #change initial input
}
