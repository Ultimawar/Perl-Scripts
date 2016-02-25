#Lec4q1a
my @months = qw (January February March April May June July August Septemeber October November December);

#Lec4q1b
print qq (@months\n);

#Lec4q1c
print qq (@months[1, 4, 9]\n); #this is called SPLICING

#Lec4q1d
my @reverse = reverse(@months);
print qq/@reverse\n/;

#Lec4q1e
my $length = ($#months+1); #this prints the index number of the last entry + 1, because entries start at 0
print qq($length\n);

#Lec4q1f
push @months, qq(new-year); #appends new-year to months
print qq(@months\n);

#Lec4q1g
@months = sort{lc($a) cmp lc($b)} (@months);
print qq(@months\n);


# Sorting works by putting left element into $a and right element into $b. We then compare the first
# char according to the ascii table. Recall cmp is the same as <=> but for strings.
# To sort alphabetically first make $a and $b lowercase, then use cmp to compare first char's in terms of
# ASCII number.
# To sort numerically, compare $a and $b using numbers version of 'cmp' aka <=>

my @numbers = (1, 55, 2892, 91, 5, 13);
@sorted = sort {$a <=> $b} @numbers;
print qq(@sorted\n);
