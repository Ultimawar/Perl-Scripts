

# Seneca College Student Oath:
#
# Oath:
#
# Student Assignment Submission Form
# ==================================
# I declare that the attached assignment is wholly my own work
# in accordance with Seneca Academic Policy.  No part of this
# assignment has been copied manually or electronically from any
# other source (including web sites) or distributed to other students.
#
# Student Name: Keshav Dial
# Student ID:	102139151

# Perl main code (YOU MUST USE THE MAIN CODE BELOW):

use strict;
use warnings;

sub stringCalc(@);

my (@strings, $result);
@strings = ("+ 5.0\n", "* 2\n", "- 1.0\n", "^ 2\n", "% 2\n", "/ 0.1\n", "+ 16.1\n", "+ 99.0\n");

# SUBROUTINE CODE: (your code below)

my $total = 0;
my ($number, $str1);

sub stringCalc(@){
	foreach $str1 (@_){
		$number = substr($str1, 2);
		$number = substr($str1, -2);
		
		if ((index($str1, '+', 0)) >= 0) {
			$total += $number;
		}
		
		if ((index($str1, '-', 0)) >= 0) {
			$total -= $number;
		}
		
		if ((index($str1, '*', 0)) >= 0) {
			$total *= $number;
		}
		
		if ((index($str1, '^', 0)) >= 0) {
			$total **= $number;
		}
		
		if ((index($str1, '/', 0)) >= 0) {
			if ($number == 0){
				print "Error: illegal operation detected...\n";
				return "ERR:NULL"
			}
			else{
				$total /= $number;
			}
		}

		if ((index($str1, '%', 0)) >= 0) {
			if ($number == 0){
				print "Error: illegal operation detected...\n";
				return "ERR:NULL"
			}
			else{
				$total %= $number;
			}
		}
	}
	
	return $total;
}


$result = stringCalc(@strings);

print "$result\n";

