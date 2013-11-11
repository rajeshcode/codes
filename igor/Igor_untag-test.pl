#!/usr/local/bin/perl 
use strict ;

my @tags; # =qw{system("cat ~/IGOR/Igortags.txt")} ;
my $role = $ARGV[0];
#open FILE , "/homes/rajeshc/IGOR/Igortags.txt" ;
open FILE , "$ARGV[1]" ;
while (<FILE>)
{

#print "$_ \n" ;
 @tags=split(/,/);
#push(@tags ,$i);
 foreach my $tag  (@tags) {#print "$_ \n "; 
print " igor untag -rules  $role $tag  \n" ;
 ` igor untag -rules  $role $tag -log " removing tags from $role"`;

  }
}
