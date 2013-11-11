#!/usr/local/bin/perl

use Getopt::Long;
use strict ;
use Data::Dumper;
use File::Basename;
use Tie::File; #### needed for setting rule  madding markets 


my $script = basename($0);
print "basename($0) \n " ;
print "$0 \n " ;


# $Farmtype   #free or partner 
# $partnertype   # att ,bizmail bt tnz verizon
# $BCPfarm
# $farmW

my $helptext = " IGOR update options 

Usage:
#  $script --farm <farm.colo>       
#  $script --bcp <farm.colo>
#  $script --type <free|partner>
#  $script --ptype <att|bizmail|bt|rogers|tnz|verizon>
#  $script --market <cnfr|eufr|infr|kpfr|sgfr|tpfr|usfr|>
";
my $farm;
my $Gtype;
my $bcp;
my $help;
my $ptype;
my $market;
my $bug;
my $type;
 

GetOptions(
    'farm=s'    => \$farm,
    'type=s'    => \$Gtype,
    'ptype=s'   => \$ptype,
    'bcp=s'     => \$bcp,
    'bug=i'     => \$bug,
    'market=s'  => \$market,
    'help!'     => \$help,
) or die "Incorrect usage! $helptext \n";

print "$farm \n" ;

print "$Gtype \n" ;
print "$ptype \n" ;
print "$bcp \n";

unless ($farm  && $bug && $Gtype) {
 print $helptext ."\n" ;
 exit 1 ;
}

$farm =~ (m/(\d+)\.(.*)/ );
my $farm1 = $1 ;
my $colo = $2 ;
my $xsetfile="/tmp/xsetmembers.$ENV{USER}";
my $xsetBCPfile="/tmp/xsetbcpmembers.$ENV{USER}";

$bcp =~ (m/(\d+)\.(.*)/ );
my $Bfarm = $1 ;
my $Bcolo = $2;


my $newrole = "mail.farm.set.$colo-prod-$farm1" ;
my $bcprole = "mail.farm.set.$Bcolo-prod-$Bfarm";

########## List or partner Roles 
#my $ mail.farm.xset.partner-att  mail.farm.xset.partner-bizmail  mail.farm.xset.partner-bt mail.farm.xset.partner-rogers mail.farm.xset.partner-tnz mail.farm.xset.partner-verizon
#####################


if ( $Gtype =~ m/partner/) {
    print "$Gtype \n " ; 
  if (!($ptype && $bcp)) { print "not defined: Give --ptype <att|bizmail> --bcp <farm.colo> \n" ; exit 1 ;} #}else { print "$ptype \n" ; }}

  print "$ptype \n " ;
  print "$bcp \n " ;

  my $partnerxset="mail.farm.xset.partner-$ptype";
  my $bcpxset ="mail.farm.xset.bcp";
  print "$partnerxset \n";
 
 #  `igor fetch -members $partnerxset -def > $xsetfile ` ;
  system("igor fetch -members $partnerxset -def > $xsetfile 2> /dev/null " ) ;
  my  @xsetmember=`cat -s "$xsetfile"`  ;
  chomp(@xsetmember);
 
  system("igor fetch -members $bcpxset -def  > $xsetBCPfile 2> /dev/null");
  my @xsetbcpmember=`cat -s "$xsetBCPfile"` ;
  chomp(@xsetbcpmember);
 
#### Test part 
#my $addr ;
#open (FH, "+<$xsetfile")               or die "can't update $xsetfile: $!";
#while ( <FH> ) {
#    $addr = tell(FH) unless eof(FH);
#}
#truncate(FH, $addr)                 or die "can't truncate $xsetfile: $!";
#close(FH);
##############

  chomp(@xsetmember);
  chomp($xsetfile); 
 
  @xsetmember=grep(!/^\s*$/, @xsetmember); #This line is to remove empty line  
  unlink($xsetfile);  #cleanup file to start fresh file 
  push(@xsetmember,"\@$newrole"); 
  foreach my $p (@xsetmember)
  {
  system ("echo -e $p >> $xsetfile");
  }
  #`igor edit -members $partnerxset -file $xsetfile -log "[Bug $bug] adding $newrole to $partnerxset `
 
  @xsetbcpmember=grep(!/^\s*$/, @xsetbcpmember);
  unlink($xsetBCPfile);
  push(@xsetbcpmember,"\@$bcprole");
  foreach my $p (@xsetbcpmember)
  {
     system("echo -e $p >> $xsetBCPfile") ; 
  }
   #`igor edit -members $bcpxset -file $xsetBCPfile -log "[Bug $bug] adding $bcprole to $bcpxset


 } 

 elsif ($Gtype =~ m/free/) 

 {
   
if (!($market )) { print "not defined: Give --market <USFR|INFR> --bcp <f
arm.colo> \n" ; exit 1 ;} #}else { print "$ptype \n" ; }}


  print "free farm \n ";
 #`igor edit -members $bcpxset -file $xsetBCPfile -log "[Bug $bug] adding $bcpro
le to $bcpxset


 }
