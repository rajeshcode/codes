#!/usr/local/bin/perl -w
  
# A generic script to fetch logs from various sources.
    
use strict;
use Getopt::Long;
use POSIX;
use yconfig;
use Thread qw (async);
use Parallel::ForkManager;
    
my $verbose; #flag variable used to indicate level of logging
=comment
# Below variables is for STATUS file. Which tracked by Grid GDM team
=cut 
my $smtpLogDirectory;
my  $hour = strftime "%H", localtime(time);
    chomp($hour);


sub gathersmtpLogNames {
  my $host= shift; 
  my $date= shift;
  my $logDirectory = shift;
  my $remoteLogDirectory=shift;
  my $logName = shift;
  my $rsyncDateForm;
  
  print "Gathering filenames for $host for date: $date\n" if $verbose;
  my $cmd="rsync --rsh='ssh' '$host:$remoteLogDirectory/$logName' ";
  if ($date =~/(\d\d\d\d)(\d\d)(\d\d)/) {
    $rsyncDateForm = "$1/$2/$3";
  }
  print "About to execute :$cmd\n" if $verbose;
  my @logNames;
  my @files = `$cmd`;
  foreach my $file (@files) {
    $file=~s/(\s+)/ /g;
    if ($file=~/$rsyncDateForm/) {
      my ($flags,$size,$moddate,$time,$filename) = split(/\s/,$file);
      push(@logNames,$filename);
      print "File : $filename\n";
    }
  }
  return \@logNames;
}

my $pm = new Parallel::ForkManager(100);

sub fetchsmtpLogs {
  my $cfg = shift;
  my $date = shift;
  my $smtphosts = shift;
  my $hostCategory = shift;
  my $logType = shift ;
  my @hosts;
  my $logname;
# my $smtpLogDirectory;
  my $smtpLogConf;
  my $remoteLogDirectory;
  my $res;
     
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
  $hour = strftime "%H", localtime(time);
  chomp($hour);
    
  if (!defined($hostCategory)) {
    print "hostCategory was not provided defaulting to us\n" if $verbose;
    $hostCategory='us';
  }
     
  ($logname,$res) = $cfg->get_value("${logType}logs","${logType}LogName");
  ($smtpLogDirectory,$res) = $cfg->get_value("${logType}logs","${logType}LogDirectory");
  ($smtpLogConf,$res) = $cfg->get_value("${logType}logs","${logType}LogConf");
  ($remoteLogDirectory,$res) = $cfg->get_value("${logType}logs","remoteLogDirectory");

  print "Using $logType conf file $smtpLogConf\n" if $verbose;
  if (!defined($smtphosts)) {
    open (SMTPLOGCONF,"<$smtpLogConf");
    @hosts = <SMTPLOGCONF>;
    close SMTPLOGCONF;
  }
  else {
    @hosts=split(/,/,$smtphosts);
 }
  my $starttime = time();

if (!( -e "$smtpLogDirectory")) {
     eval {
           mkdir("$smtpLogDirectory", 0755) or
           die "Failed to create directory $smtpLogDirectory";
     };
     if ($@) {
         print STDERR "WARN: failed to create directory $smtpLogDirectory";
         next;
      }
   }
    
  if (!( -e "$smtpLogDirectory/$date$hour" )) {
    eval {
      mkdir("$smtpLogDirectory/$date$hour",0755) or
        die "Failed to create directory $smtpLogDirectory/$date$hour";
    };
    if ($@) {
      print STDERR "WARN: failed to create directory $smtpLogDirectory/$date$hour";
      next;
    }
  }
    
  print "Starting smtp LogTransfer at ".scalar(localtime($starttime))."\n";
  $pm->run_on_start(
       sub {
            my ($pid,$ident) = @_;
            # in case that you don't provide an identifier in the call to start, this will make $ident be undefine
d and cause the Perl interpreter to complain (if you are using strict and warnings)
            #
            print "Starting processes $ident under process id $pid\n" if $verbose;
       }
  );
       
  $pm->run_on_finish(
       sub {
            my ( $pid, $exit_code, $ident, $signal, $core ) = @_;
            if ( $core ) {
               print "Process $ident (pid: $pid) core dumped.\n";
            } else {
                print "Process $ident (pid: $pid) exited\n"  if $verbose;
                print "with code $exit_code and signal $signal.\n" if $ verbose ;
              }
       }
  );
    
      
  foreach my $host (@hosts) {
    chomp $host;
   
    $pm->start and next;
  
    my @fnames = split(/,/,$logname);
    foreach my $fname (@fnames) {
      my $cmd = "rsync -avvz --progress --rsh='ssh -q' $host:$remoteLogDirectory/$fname $smtpLogDirectory/$date$ho
ur/$host.$fname";


      print "about to fetch smtp log $remoteLogDirectory/$fname for $host\n" if $verbose;
      my $hoststarttime = time();
      print "Starting $logType LogTransfer for $host at ".scalar(localtime($hoststarttime))."\n";
      print "executing command : $cmd \n" if $verbose;
      eval { system($cmd)==0 or die "system $cmd failed:$?"};
  
      open (DONE, ">>$smtpLogDirectory/$date$hour/DONE.smtp");
      open (HEADER, ">$smtpLogDirectory/$date$hour/HEADER.smtp");
      open (ROWCOUNT, ">$smtpLogDirectory/$date$hour/ROWCOUNT.smtp");
      #print STATUS "$smtpLogDirectory/$date$hour/DONE.smtp" ;
      #print DONE  "$smtpLogDirectory/$date$hour/$host.$fname\n" ;
                
      if (!($@)) {
        my $hostendtime=time();
        print "Finished smtp LogTransfer for $host at ".scalar(localtime($hostendtime))."\n";
        print "fetched logs for $host\n" if $verbose;
        print DONE  "$smtpLogDirectory/$date$hour/$host.$fname\n" ;
      }
      else {
        print STDERR "WARN: failed to fetch smtplogs from $host\n";
      }
    }
     $pm->finish;
  }
  $pm->wait_all_children;
  print "Everybody is out of the pool!\n" if $verbose;

  my $endtime=time();
print "Finished smtp LogTransfer at ".scalar(localtime($endtime))."\n";
  print "Total Transfer took ".($endtime-$starttime)." seconds\n";
}
      
      
sub main() {
  my $confFile; # = "/home/rajeshc/mailsedata_collector/dataFramework.conf";
  my $logType;
  my $smtphosts;
  my $hostCategory;
      
  my $ts = time();
  my $date = strftime "%Y%m%d",localtime($ts);
        
  my $result = GetOptions ("date=s"=>\$date,
                           "conf=s" =>\$confFile,
                           "type=s" =>\$logType,
                           "verbose+"  => \$verbose,
                           "smtphost=s"=>\$smtphosts,
                           "hostCategory=s"=>\$hostCategory);
       
  if (!$result) {
    print STDERR "Usage fetchLogs.pl --date=YYYYMMDD --conf=<conffile> --type=<smtp|reggate|popgate> --hostCategor
y=<us|intl> --verbose \n";
    exit(1);
  }

  if ((!defined($logType)) || (!($logType=~/(smtp|reggate|popgate)/)))  {

    print STDERR "--type option missing \n";
    print STDERR "Usage fetchLogs.pl --date=YYYYMMDD --conf=<conffile> --type=<smtp|reggate|popgate> --verbose \n"
;   
    exit(1);
  }   

  my $cfg = new yconfig::yConfigFile();
  my ($root,$res) = $cfg->load($confFile,{},{},"ini");
  
  if (!yconfig::yconfig_is_success($res)) {
    print STDERR "ERROR: unable to parse config file : $confFile\n";
    exit(1);
  }
  if (!yconfig::yconfig_is_valid_node($root)) {
    print STDERR "ERROR: unable to parse config file : $confFile\n";
    exit(1);
  }
                           
  print "Fetching $logType logs for date=$date using $confFile\n" if $verbose;
                           
  if ($logType=~/^smtp$/) {
     if (defined($hostCategory) && $hostCategory=~/ukl/ && (!defined($date))) {
        $ts-=86400;#go back one day as for ukl the logs get rotated 11:59 GMT
         $date = strftime "%Y%m%d",localtime($ts);
    }
    fetchsmtpLogs($cfg,$date,$smtphosts,$hostCategory,$logType);
  }
  elsif ($logType=~/^reggate/) {
     $date = strftime "%Y%m%d",localtime($ts);
        fetchsmtpLogs($cfg, $date,$smtphosts , $hostCategory,$logType);
  }
  elsif ($logType=~/^popgate/) {
         $date = strftime "%Y%m%d",localtime($ts);
         fetchsmtpLogs($cfg, $date,$smtphosts , $hostCategory,$logType);
   
# Popgate is the last iteration. So added STATUS file here .( Its cracky way Need to remove this part out of this
script, TODO)
         open (STATUS, ">$smtpLogDirectory/$date$hour/STATUS.smtp");
         print STATUS "$smtpLogDirectory/$date$hour/DONE.smtp";
     
  }
         
}   
    
main();

