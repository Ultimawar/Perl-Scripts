# AUTHOR: KESHAV DIAL
# I declare that the attached assignment is wholly my own work in accordance with
# Seneca Academic Policy. No part of this assignment has been copied manually or
# electronically from any other source (including web sites) or distributed to other students.
# Name: Keshav Dial
# ID: 250526958
# COURSE: BIF724
# ASSIGNMENT: #1
# NAME OF PROGRAM: keshav_a1_lib.pl
# PURPOSE: This program is the library file. This file stores all of the subroutines used in the other perl programs (keshav_a1_add.cgi, keshav_a1_upload.cgi, keshav_a1_view.cgi).

sub create_text_input () {
    # REQUIRES: CGI; This subroutine accepts a name for the div element ($k), a description for the input (%hash1's value), a reference to a cgi function decribing which form input to use ($type), the $fail_switch value to indicate whether or not return the submitted value to the form, and the hash of submitted values ($hash2) to retun 
    my $cgi = new CGI;
    my($k, $type, $fail_switch, %hash1, %hash2) = @_;
    return(div({-id=>$k,-class=>'input'}, a($hash1{$k}), $type->($k.'_text', $fail_switch==1?('-value='.$cgi->escapeHTML($hash2{$k})):'')));
}
sub add_breaks(){
    # This function is used to add breaks to each element in an array. This is used for printing errors and broken entries.
    foreach(@_){
        $_ = $_."<br>";
    }
}
sub create_errors_div(){
    # This will print the broken entries if a -bad_entry flag is passed. It will print the number of errors if no flag is passed. The function requires an array of errors or entries as input.
    if ($_[0] eq "-bad_entry") {
        shift @_; # Removes -bad_entry flag
        return div({-id=>'error', -class=>'warnings'}, a("<strong>The following entries elicited errors:</strong><br>@_"));
    }else{    
        return div({-id=>'error', -class=>'warnings'}, a("<strong>You have ",(scalar @_), (scalar @_ > 1)?("errors!"):("error!"), "</strong><br>@_"));
    }
}
sub create_success_div(){
    # Requires CGI qw(:standard);This returns HTML referring to a green box and a success message.
    return div({-id=>'success', -class=>'success'}, a("Sucessfully processed your request <br><br>"));
}
sub create_menu_ul(){
    # Returns HTML of an unordered list that links to other CGI pages.
    return '<ul><li><a href="keshav_a1_add.cgi">Add A Record</a></li><li><a href="keshav_a1_view.cgi">View All Records</a></li><li><a href="keshav_a1_upload.cgi">Upload A File</a></li></ul>';
}
sub re1_check(){
    #Accepts the split re1_id array and validates each of it's entries.
    my @split_re1_id = @_;
    my @error_array;
    unless($split_re1_id[0]){
    push @error_array, "ERROR: RE1_ID FIELD IS EMPTY! TIP: Enter an RE1_ID.";
    }else{
        unless ($split_re1_id[0] =~/^rat$|^opossum$|^human$|^xenopus$|^chicken$/){
            push @error_array, "ERROR: INCORRECT SPECIES NAME IN RE1_ID! TIP: Form is case sensitive! Double check your spelling and casing.";
        }
        unless($split_re1_id[1] == 42){
            push @error_array, "ERROR: INCORRECT ENSEMBL DATABASE NUMBER IN RE1_ID! TIP: The correct number is 42.";
        }
        unless($split_re1_id[2] =~/^[0-9]{1,2}?[a-z]?$/){
            push @error_array, "ERROR: INCORRECT VERSION NUMBER IN RE1_ID! TIP: Form is case and type sensitive! Verison number has 1 or 2 digits followed by an optional lowercase letter.";   
        }
        unless($split_re1_id[3] =~/^scaffold$|^[0-9]$|^[0-9][0-9]$|^[W-Z]$/){
            push @error_array, "ERROR: INCORRECT REGION NAME IN RE1_ID! TIP: Form is case sensitive! Region name is either scaffold_(1-7 digits), an uppercase letter W-Z, or a chromosome number";
        }
        if ($split_re1_id[3] eq 'scaffold') {
            unless ($split_re1_id[4] =~ /^[0-9]{1,7}$/){
                push @error_array, "ERROR: INCORRECT REGION NAME IN RE1_ID! TIP: scaffold is followed by only 1 to 7 digits"; 
            }
            unless($split_re1_id[5] =~ /^[0-9]{1,9}$/){
                push @error_array, "ERROR: INCORRECT POSITION ON THE REGION IN RE1_ID! TIP: position is limited to a maximum of 9 digits";
            }
            unless($split_re1_id[6] =~ /^f$|^r$/){
                push @error_array, "ERROR: INCORRECT STRAND IN RE1_ID! TIP: strand is either 'f' or 'r'";
            }
        } else {
            unless($split_re1_id[4] =~ /^[0-9]{1,9}$/){
                push @error_array, "ERROR: INCORRECT POSITION ON THE REGION IN RE1_ID! TIP: position is limited to a maximum of 9 digits";
            }
            unless($split_re1_id[5] =~ /^f$|^r$/){
                push @error_array, "ERROR: INCORRECT STRAND IN RE1_ID! TIP: strand is either 'f' or 'r'";
            }
        }
    }
    return @error_array;
}
sub score_check(){
    # Accepts the score value ($score_text) and validates it.
    my $score_text = $_[0];
    my @errors_array;
    unless ($score_text){
        push @errors_array, "ERROR: NO VALUE ENTERED INTO SCORE VALUE! TIP: Enter a score value.";
    }else{
        unless($score_text=~ /^(0\.[0-9]{1,4}$)|^1$/){
            push @errors_array, "ERROR: INCORRECT SCORE VALUE! TIP: Scores only have room for 4 digits after the leading 0 in a decimal, or a single digit '1'";
        }
        unless(($score_text ge 0.91) && ($score_text le 1)){
            push @errors_array, "ERROR: INCORRECT SCORE VALUE! TIP: Scores must be above or equal to 0.91 and smaller or equal to 1.";
        }
    }
    return @errors_array;
}
sub target_gene_check(){
    # Accepts the target gene value ($target_gene_id_text) and validates it
    my $target_gene_id_text = $_[0];
    my @errors_array;
    unless ($target_gene_id_text){
        push @errors_array, "ERROR: TARGET GENE ID IS EMPTY! TIP: Enter a Target Gene ID.";
    }else{
        unless($target_gene_id_text=~ /(ENS(G{1}|[A-Z]{3}G)[0-9]{11})/){
            push @errors_array, "ERROR: INCORRECT TARGET GENE ID ENTERED! TIP: Make sure your Gene ID follows formatting i.e. ENS, either a 'G' or 3 letters followed by a 'G', and then 11 digits";
        }
    }
     return @errors_array;
}
sub position_check(){
    # Accepts the position of the RE1 gene ($position_re1_relative_text) and validates it against the hash %position_re1_possibilities
    my %position_re1_possibilities=("3'","3'","5'","5'","exon","exon","EXON","EXON","intron","intron","INTRON","INTRON","exon+","exon+","EXON+", "EXON+","intron+","intron+","INTRON+","INTRON+");
    my $position_re1_relative_text = $_[0];
    my @errors_array;
    
    unless($position_re1_relative_text){
        push @errors_array, "ERROR: NO VALUE ENTERED FOR POSITION OF RE1! TIP: Enter a position.";
    }else{    
        unless(exists($position_re1_possibilities{$position_re1_relative_text})){
            my @possibilities = sort values %position_re1_possibilities;
            push @errors_array, ("ERROR: INCORRECT POSITION OF Re1 ENTERED! TIP: Enter one of the following: @possibilities");
        }
    }
    return @errors_array;
}
sub orientation_check(){
    # Accepts the gene strand orientation ($gene_strand_radio) and validates it
    my $gene_strand_radio=$_[0];
    my @errors_array;
    unless ($gene_strand_radio eq "+" | $gene_strand_radio eq "-") {
        push @errors_array, "ERROR: NO GENE STRAND ORIENTATION SELECTED! TIP: Select one of the radio buttons";
    }
    return @errors_array;
}

sub gene_description_check(){
    # Accepts the gene description ($gene_description_textarea) and validates it.
    my $gene_description_textarea=$_[0];
    my @errors_array;
    if ($gene_description_textarea=~/'|"|,|\\|\//g) {
         push @errors_array, "ERROR: INCORRECT DESCRIPTION! TIP: Don't use illegal characters";   
        }
    return @errors_array;
}
sub upload_form(){
    # Returns HTML cooresponding to the FILE UPLOAD form and a submit button.
        return <<E;
        <div id=file_upload>
            <a>File To Upload:</a>
            <input class='input' type="file" name="up_file"><br>
            <input type='submit'>
        </div>
    </form>
E
}
sub duplication_check(){
    # REQUIRES DBI. Accepts Re1 ID as input ($re1_id), and then runs an SQL query to check if it has already been added to the database
    my $password = get_paswd();
    my $dbh = DBI->connect("DBI:mysql:host=db-mysql;database=bif724_161a07", 'bif724_161a07', $password) or die("ERROR: Cannot connect to database".DBI->errstr);
    my $re1_id = $_[0];
    my $sql_duplication_check = "SELECT * FROM a1_data where re1_id = ?";
    my $sth_duplication_check = $dbh->prepare($sql_duplication_check) or die "ERROR: Problem with prepare statement for duplication check";
    my $duplication_check = $sth_duplication_check->execute($re1_id);
    if ($duplication_check>0) {
        return "ERROR: DUPLICATED ENTRY! TIP: Enter another re1_id";
    }else{
        return"";
    } 
}

sub cross_check(){
    # Accepts the species name from the split re1_id array ($split_re1[0]) and the target gene id ($target_gene_id) and cross verifies the two against each other, confirming whether the two correlate.
    my ($species_name, $target_gene_id) = @_;
    my @errors_array;
    if ($species_name =~/^rat$/) {
        unless ($target_gene_id =~ /^ENSRNOG/){
            push (@errors_array, "ERROR: Target Gene ID doesn't not correspond to rat! TIP: Start Gene ID with 'ENSRNOG'");
        }
    }
    if ($species_name =~/^human$/) {
        unless ($target_gene_id =~ /^ENSG/){
            push (@errors_array, "ERROR: Target Gene ID doesn't not correspond to human! TIP: Start Gene ID with 'ENSG'");
        }
    }
    if ($species_name =~/^chicken$/) {
        unless ($target_gene_id =~ /^ENSGALG/){
            push (@errors_array, "ERROR: Target Gene ID doesn't not correspond to chicken! TIP: Start Gene ID with 'ENSGALG'");
        }
    }
    if ($species_name =~/^opossum$/) {
        unless ($target_gene_id =~ /^ENSMODG/){
            push (@errors_array, "ERROR: Target Gene ID doesn't not correspond to opossum! TIP: Start Gene ID with 'ENSMODG'");
        }
    }
    if ($species_name =~/^xenopus$/) {
        unless ($target_gene_id =~ /^ENSXET/){
            push (@errors_array, "ERROR: Target Gene ID doesn't not correspond to xenopus! TIP: Start Gene ID with 'ENSXETG'");
        }
    }
    return @errors_array;
}

sub starter_html(){
    ### RETURNS REQUIRED HTML INFORMATION FOR UPLOAD PAGE###
    return header(), start_html(-title=>"Upload File to RE1 target gene data", -style=>{'src'=>'/~bif724_161a07/styles/keshav_a1.css'}), "<link href='https://fonts.googleapis.com/css?family=Open+Sans:400,600' rel='stylesheet' type='text/css'>", create_menu_ul(), h1('RE1 target gene data'), p('Choose a CSV file containing the entries you wish to upload to the RE1 target gene database and press submit. Upon submission the data will be verified. Entries that pass selection will be added to the database. Entries that present problems will be returned in an error box. If all entries are successfully added to the database, you will be forwarded to the "VIEW ALL RECORDS" page.'), "<br>";
}
1;
