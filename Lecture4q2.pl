#Lec4q2a
my @numbers = (0..999);

#Lec4q2b
print qq($numbers[0] @numbers[100..120] $numbers[-1]\n); # 1. Scalar Element View 
														 # 2. Splicing array. 
														 # 3. Scalar element view with negative index for last entry.
#Lec4q2c
pop(@numbers); #will 'pop' off the last entry

#Lec4q2d
@numbers = sort {$a <=> $b} @numbers; 

# Sorting works by putting left element into $a and right element into $b. We then compare the first
# char according to the ascii table. Recall cmp is the same as <=> but for strings.
# To sort alphabetically first make $a and $b lowercase, then use cmp to compare first char's in terms of
# ASCII number.
# To sort numerically, compare $a and $b using numbers version of 'cmp' aka <=>
