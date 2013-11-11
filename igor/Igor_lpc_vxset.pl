#!/usr/local/bin/perl
####
#This script is to update the lpc value of the mixo2's for VX Server 
#######

use strict;
use Getopt::Long;
use File::Basename;
use Igor::Client ;
use Socket;

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

my $rolewheretoadd ;
my @rules ;
my $rules1;
my $log;

unless ($farm  &&  $isbiz && $bug) {
 print $helptext ."\n" ;
 exit 1 ;
}
     $farm =~ (m/(\d+)\.(.*)/ );
    my $farm1 = $1 ;
    my $colo = $2 ;
$log="[Bug $bug] updating lpc (Testing )";
my $host ;

if ($isbiz =~ m/biz/)
{
  $host = "web".$farm1."02.biz.mail.$colo.yahoo.com" ;
 chomp($$host);


}else {

  $host = "web".$farm1."02.mail.$colo.yahoo.com" ;
 chomp($host);
}


my $hostaddr = gethostbyname($host);
my $lenaddr = length($hostaddr);

print "$hostaddr \n " ;
print "$host \n" ;
print "$lenaddr \n \n " ;

my $h ;
$h = system("yinst ssh  -remote_timeout 20  -h  $host  2>/dev/null");
if ($h !=0 )
{
print "\n$host not sshable. Trying another host..";

exit ;
}
my @a = `yssh $host "cat /etc/four11conf/LockServers 2> /dev/null"`;
if(@a == () )
{ 
  print "\nLockservers file not found in $host. Exitting\n\n";

  exit;
}

foreach my  $i (@a) 
{
 print "$i \n \n " ;
}


my $k ;
my @mixhost;
for(my $i=0;$i<= $#a;$i++)
{
  if($a[$i] =~ m/^$/i )
  {
  }
  else
  {
    #my ${h . $i};
    my $iaddr = inet_aton($a[$i]);
     $k = gethostbyaddr($iaddr, AF_INET);
 $k =~ s/^\s+$//;
 print " Test $k \n " ;
 chomp($k);
  if ($k =~ /mix(\d+)(\d{2})/)
  {
   $k=$1;
   print "$k  Hai \n ";
  }

push(@mixhost , $k);
  }
#print "$k \n "; 
#push(@mixhost , $k);
}

#print "${h . $i} \n "

foreach my $t (@mixhost) 
{ #print "$t \n " ;
  chomp($t); 
  if ($t !~ m/$farm1/ )
    {
    
      my $editrole="mail.farm.set.$colo-prod-$t" ;
      print "$editrole \n " ;
      &UpdateLpc ({

          rolewheretoadd => $editrole,
       });

     }
}
OUT: 
my $validlpc;
sub UpdateLpc {
#o $client->fetch_role_rules($name, $rev, FH);
my ($args) = @_;


@rules = $c->fetch_role_rules($args->{rolewheretoadd},undef);

     foreach my $x (@rules) 
      { print "$x  \n " ;
           if ($x =~ m/ymail_lpc_ls_config/)
            {
             chomp($x);
              $validlpc = $x;
#             my @lpc = map({[split/,/]} $x);
             my @lpc = (split /=/ ,  $x);
               # @lpc =grep(/[\d,]+/ , $lpc[1]);
                print "$lpc[1] \n \n"  ;
                 @lpc = (split /,/ , $lpc[1]) ;
#                 @lpc = (split /[\d*],/ , @lpc) ;
#                @lpc = (split ',' , @lpc);
                 
                 foreach my $p (@lpc) 
                  { print " Hai $p \n \n " ;
                    if ($p =~ m/$farm1/ ) 
                        {
                            print "$p exists \n " ;
                            goto OUT;
                        }else {
                              } 
                  }
            }
=mycoomnet
 print " COmmnet  -----  \n "
            
# s/ymail_lpc_ls_config.farm_list=[\d,]{2,}/ymail_lpc_ls_config.farm_list=(split(,@mixhost/g;
=cut
      }
#=Rcomment
 $validlpc=$validlpc . "," . $farm1 ;
 print "$farm1 \n " ;
 print "$validlpc  Check this \n \n  " ;
#=cut
$_=~s/^10 add yinst setting ymail_lpc_ls_config.farm_list=[\d*,]*/$validlpc/ foreach (@rules);
print "CHANGED $_ \n"  foreach(@rules);
$rules1=join ("\n" , @rules);
#$rules1=$c->fetch_role_rules($args->{rolewheretoadd},undef);
print "HHHHHHHHHHHHH $rules1 \n ";
#if ( $rules1 = 
chomp($rules1);
$c->set_rules($args->{rolewheretoadd}, $log,$rules1); 
}
 

