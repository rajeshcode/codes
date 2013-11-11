#!/usr/local/bin/perl
########To set rules for a set role###
use Tie::File;
use strict;

my $farm=$ARGV[0] ;
#my $isbiz=$ARGV[1] ;
my $udbrepl = $ARGV[1] ;
my $bug=$ARGV[2] ;
print "$farm \n ";
my $rulefile="/tmp/rule.$ENV{USER}";

$farm =~ (m/(\d+)\.(.*)/ );
my $farm1 = $1 ;
my $colo = $2 ;

my @samprule=`igor fetch -rules mail.farm.set.gq1-prod-1100`;
if (scalar(@samprule)>0) {
      print scalar(@samprule) . "\n" ;
}
open (RULFILE, ">$rulefile");
foreach my $x (@samprule) {
#print "$x ";
print RULFILE "$x" ;
}
close(RULFILE);

my %timezone = (
             ukl => 'GMT', 
             ird => 'GMT', 
             aue => "Australia/Sydney",
             cnb => 'Asia/Shanghai',
             cnh => 'Asia/Shanghai',
             cn3 => 'Asia/Shanghai',
             cnh => 'Asia/Shanghai',
             tp2 => 'Asia/Taipei',
             tpe => 'Asia/Taipei',
             in  => 'Asia/Calcutta',
             in2 => 'Asia/Calcutta',
             krs => 'Asia/Seoul',
             kr3 => 'Asia/Seoul',
             kr1 => 'Asia/Seoul',
             sg1 => 'Asia/Singapore',
             mud => 'US/Pacific',
dcn => 'US/Pacific',
re1 => 'US/Pacific',
re2 => 'US/Pacific',
re3 => 'US/Pacific',
re4 => 'US/Pacific',
scd => 'US/Pacific',
sp1 => 'US/Pacific',
ac2 => 'US/Pacific',
ac4 => 'US/Pacific',
sk1 => 'US/Pacific',
gq1 => 'US/Pacific',

);

 

my @lines=();
tie @lines, 'Tie::File', "$rulefile" or die "Can't read file: $!\n";
foreach ( @lines )
{
  s/udbclient.service=gqa/udbclient.service=$udbrepl/g;
  s/ymail_lpc_ls_config.farm_list=[\d,]{2,}/ymail_lpc_ls_config.farm_list=$farm1/g;
  s/root.timezone=US\/Pacific/root.timezone=$timezone{$colo}/g; 
}
untie @lines;
my $newrole="mail.farm.set.$colo-prod-$farm1";
####check if rule exist before updating 
#`igor edit -rules  $newrole  -file $rulefile -log "[ Bug bug ] adding rules (Testing)"`
print "$newrole \n";
print $timezone{$colo}."\n" ;

