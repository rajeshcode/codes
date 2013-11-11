#!/usr/local/bin/perl 
 
my $farm=$ARGV[0] ;
my $isbiz=$ARGV[1] ;
my $bug=$ARGV[2] ;
print "$farm \n ";
my $Hostfile="~/Ifarmsetrule" ;
$farm =~ (m/(\d+)\.(.*)/ );
my $farm1 = $1 ;
my $colo = $2 ;

print "$farm \n ";
#@Rolelist=system("igor list -roles  mail.farm.set.$colo*");
#my @Rolelist=`igor list -roles  mail.farm.set.$colo*`;

foreach my $h (@Rolelist)

{
 print "$h \n ";
}
	
#my %Rolelist = map { $_->[0] => 1 } @Rolelist;

my $newrole = "mail.farm.set.$colo-prod-$farm1" ;
chomp($newrole);
#chop($newrole);
# print "$newrole \n " ;
#print "$Rolelist{$newrole} ihai \n"; 
#if ($Rolelist{$newrole}) 
#if ( grep { $_->[0] eq $newrole } @Rolelist )
my %elements;
foreach (@Rolelist) {
 $Rolelist{$_} = 1;
};
if (exists $Rolelist{$newrole})
{
 print "found \n ";
}
if ( grep {$_ =~ m/$newrole/} @Rolelist )
{
  print " $newrole exists \n ";
} else 
  { 
#    system("igor create -role $newrole -log " Bug $bug  adding new role for  testing the automate tool $farm" ")  ;
#`igor create -role $newrole -log " [Bug $bug]  adding new role for  (testing the automate script) $farm" `  ;
  } 
 

#=======
my $memregex="\@mail.farm.all,&/[^0-9]$farm1\\d\\d\\.mail\\.($colo\\.)?yahoo/" ;
#print "$memregex \n ";

my $memregxfile="/tmp/IhostRegx.$ENV{USER}" ;

open (MYFILE, ">$memregxfile");

chomp($memregex);

print MYFILE "$memregex \n" ;

close (MYFILE);

#igor edit -members $newrole -log "[Bug $bug] adding regex (Testing) for member" -file $meregxfile  

