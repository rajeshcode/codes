#!/usr/local/bin/perl

##########
##### This script is to populate mail.farm.all members & to add member regex role and to Tag the New farm set role and hosts
##########


use strict;
use Getopt::Long;
use File::Basename;
use Igor::Client ;

my $user = getpwuid($>);
my $c = new Igor::Client($ENV{'IGOR_URL'}, $ENV{'IGOR_PROPERTY'}, $user);


my $farm ;
my $isbiz ;
my $bug ;
my $bcp ;
my $Gtype;
my $ptype;
my $udbrepl ; ### needed for set rule
my $tag;
my $help ;

my $script = basename($0);
#my $farm=$ARGV[0] ;
#my $isbiz=$ARGV[1] ;
#my $bug=$ARGV[2] ;
print "$farm \n ";


my $helptext = " IGOR update options

Usage:
 $script --farm <farm.colo>   --bug <bugnumber> --isbiz <biz|no> --tag <mail.farm.prod.X_XXXXX> | -f <farm.colo> -b <bugnumber> -is <biz|no>


";


GetOptions(
    'farm=s'    => \$farm,
    'type=s'    => \$Gtype,
    'ptype=s'   => \$ptype,
    'bcp=s'     => \$bcp,
    'bug=i'     => \$bug,
    'isbiz=s'   => \$isbiz,
    'udbrepl=s' => \$udbrepl,
    'tag=s'     => \$tag,
    'help!'     => \$help,
) or die "Incorrect usage! $helptext \n";

print "$farm \n ";
print "$bug \n";
print "$isbiz \n ";

unless ($farm  && $bug && $isbiz && $tag ) {
 print $helptext ."\n" ;
 exit 1 ;
}

#-----------------

my $Hostfile="/tmp/Hostlist.$ENV{USER}";
my $memregxfile="/tmp/IhostRegx.$ENV{USER}" ;


system("igor fetch -members mail.farm.all > $Hostfile") ;
$farm =~ (m/(\d+)\.(.*)/ );
my $farm1 = $1 ;
my $colo = $2 ;
 print "$farm1 , $colo";
######c Role 
my $newrole = "mail.farm.set.$colo-prod-$farm1" ;
chomp($newrole);
######


#====== To check bizmail ===========
#my $x = `host f$farm1.mail.vip.$colo.yahoo.com`;

#my $y = `host b$farm1.mail.vip.$colo.yaho.com` ;
#if ( $x =~ m/Host not found/)
#{
 #print "trure" ;}
# else { print "false";}

print "$isbiz \n" ;
my $mix1;
my $mix2;

##### Tag part is manual now  ????? ToDO

my $currentTag=`igor fetch -host mix94001.mail.in2.yahoo.com `;
 print  "$currentTag \n" ;
my @tag=split(/=/,$currentTag);
print "$tag[1] \n";
############



my $memregex;
if ($isbiz =~ m/biz/) 
{
 $mix1 = "mix".$farm1."01.biz.mail.$colo.yahoo.com" ;
 $mix2 = "mix".$farm1."02.biz.mail.$colo.yahoo.com" ;
 chomp($mix1);
 chomp($mix2);

 $memregex="\@mail.farm.all,&/[^0-9]$farm1\\d\\d\\.biz\\.mail\\.($colo\\.)?yahoo/" ;
chomp($memregex);

}else {

 $mix1 = "mix".$farm1."01.mail.$colo.yahoo.com" ;
 $mix2 = "mix".$farm1."02.mail.$colo.yahoo.com" ;
 chomp($mix1 ,$mix2);
  $memregex="\@mail.farm.all,&/[^0-9]$farm1\\d\\d\\.mail\\.($colo\\.)?yahoo/" ;

 chomp($memregex);

 }



print " $mix1 & $mix2 \n " ;
my $x =`host $mix1 2> /dev/null`;
my $y =`host $mix2 2> /dev/null`;
#if ($x =~ m/has address/ && $y =~ m/has address/)
# {
 my @mixhosts=($mix1,$mix2);

 foreach my $p (@mixhosts)
 {
 system ("echo $p >> $Hostfile");
 }
 
 #system ("igor edit -members mail.farm.all -file $Hostfile -log "[Bug $bug] added $mix1 7 $mix2"  ");

` igor edit -members mail.farm.all -file $Hostfile -log "[Bug $bug] added $mix1 & $mix2"` ;
#  }
#else { print "Host ==$mix1 & $mix2== not found in DNS\n" ; exit;} 


#### adding member regex to farm set role######

open (MYFILE, ">$memregxfile");

print " $memregex   \n" ;
print MYFILE "$memregex \n" ;

close (MYFILE);

`igor edit -members $newrole  -file $memregxfile -log "[Bug $bug] adding regex "`;

print "Added $memregex to $newrole  \n \n " ;



######Tagging ur role and hosts
&setTag({

    farm => $farm ,
    tag => $tag,
});


sub setTag {
    my ($args) = @_;
    $args->{farm} =~ (m/(\d+)\.(.*)/ );
    my $farm1 = $1 ;
    my $colo = $2 ;
    my $newrole = "mail.farm.set.$colo-prod-$farm1" ;
    print ("Tagging HEAD revision for $newrole with Tag $args->{tag} \n \n");


#####Tagging the farm set role (UNDEF is equivalent to FLOAT )
$c->tag_rules($newrole,"$args->{tag}",undef,"Taging the set role $args->{tag} .");

print ("\n Tagging members of  $newrole with Tag $args->{tag} \n");
###  $client->tag_members($name, $tag, $rev, $log); this is not implemented yet in igor::client igor_client-1.4.16


######$c->tag_members('mix110601.mail.gq1.yahoo.com',$args->{tag},undef ,"[Bug 2228021] Tagging host with $args->{tag}");

`igor tag -host "\@$newrole"  $args->{tag} -log  "[Bug $bug] members of $newrole with $args->{tag}"` ;

}




