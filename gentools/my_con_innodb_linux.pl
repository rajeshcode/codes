!/usr/bin/perl -w
#
# my_con
# MY_CON generates a running report of MySQL instance statistics to quickly pinpoint database problems.
#
# Adapted from FREE_CON, May 2007 by John Feibusch
# 

use lib "/usr/share/perl5";              # This allows perl to find the LWP::Simple module

use strict;
use DBI;
use Getopt::Long;
use Socket;
use POSIX qw(uname);
use LWP::Simple;
#require "/export/home/mysql/bin/utils.pl";

my $HOME=$ENV{'HOME'};
require "$HOME/bin/utils.pl";

my $syntax="Usage: my_con [--socket_file <socket>] [--user <mysql_user>] [--password <password>] [--cycle <cycle_time>] [--output <output file>] [--version]";

my ($socketFile,$mysqlUser,$mysqlPwd,$cycle_time,$outputFilename,$printVersion);
my %newdata;
my %olddata;

GetOptions("socket_file=s",\$socketFile,"user=s",\$mysqlUser,"password=s",\$mysqlPwd,"cycle=i",\$cycle_time,"output=s",\$outputFilename,
     "version",\$printVersion)
  or die "$syntax\n";

if ($printVersion) {
   print "MY_CON version 0.3\n";
   exit;
}
$socketFile="/tmp/mysql.sock" if ! $socketFile;

$cycle_time=10 if !defined $cycle_time;
$outputFilename="$HOME/MY_CON" if !defined $outputFilename;

my $outputFilenameMain   = $outputFilename.".log";
my $outputFilenameSYS    = $outputFilename."_SYS.log";
my $outputFilenameInnoDB = $outputFilename."_InnoDB.log";


my $dbh=DBI->connect("DBI:mysql:database=information_schema:mysql_socket=${socketFile}","mysql_monitor","mysql_monitor",{ RaiseError => 0, PrintError => 0 });
if (! $dbh ) {
    my $pass = &get_root_pass;
    $dbh=DBI->connect("DBI:mysql:database=information_schema:mysql_socket=${socketFile}","root",$pass);
};

$dbh->{FetchHashKeyName}="NAME_lc";
$dbh->{RaiseError}=1;

my $statStmt=$dbh->prepare("show global status");

my $date;
my $load;

my $pageCounter=0;
my $cycleStart=time;
my $cycleElapsed=0;

my ($slave, $dir);
my ($runque,$swpd,$freeMem,$si,$so,$bi,$bo,$userCPU,$sysCPU,$idleCPU,$wa,$rss_mysql,$svctm_log,$util_log,$svctm_innodb_data,$util_innodb_data,$svctm_datadir,$util_datadir);

while (1) {
  if (!($pageCounter++%24)) { # Print header every 24 lines
     &open_output;
     print MAIN_FILE "                Execs  Select  Update  Insert Delete";
     print MAIN_FILE "  Load  Login  TotSess  ActSess  Wait   Immed  Bytes_R Bytes_S Sortrow Delay\n";
     print SYS_FILE "              VirMem FreeMem SwapI  SwapO   RSS     RunQ  User  Sys  Idle  Wait";
     print SYS_FILE " svctm_log util_log svctm_In util_In svctm_DT util_DT\n";
         print INNO_FILE "                Data_W Data_R  Log_W  D_fync L_fync Curr_Lock";
     print INNO_FILE " Lock_tim PageData PageFree PageFlush DiskRead Dblwr_w PageRe PageWri\n";
  }


  #check if the slave and delay, if not print out -1
  my $slaveStmt=$dbh->prepare("show slave status");
      $slaveStmt->execute();
  my $slaveRef=$slaveStmt->fetchrow_hashref();

  if (! defined  $slaveRef->{'seconds_behind_master'}) {
     $slave=-1;
  } else {
     $slave=$slaveRef->{'seconds_behind_master'};
  }

  my $statRef=$dbh->selectall_hashref($statStmt,'variable_name');
  $newdata{logins}=$statRef->{Connections}->{value};
  $newdata{executions}=$statRef->{Queries}->{value};
  $newdata{selects}=$statRef->{Com_select}->{value};
  $newdata{updates}=$statRef->{Com_update}->{value};
  $newdata{inserts}=$statRef->{Com_insert}->{value};
  $newdata{deletes}=$statRef->{Com_delete}->{value};
  $newdata{total_sessions}=$statRef->{Threads_connected}->{value};
  $newdata{active_sessions}=$statRef->{Threads_running}->{value};
  $newdata{locks_immediate}=$statRef->{Table_locks_immediate}->{value};
  $newdata{locks_waited}=$statRef->{Table_locks_waited}->{value};
  $newdata{bytes_received}=$statRef->{Bytes_received}->{value};
  $newdata{bytes_sent}=$statRef->{Bytes_sent}->{value};
  $newdata{sort_rows}=$statRef->{Sort_rows}->{value};

  #for innodb status
  $newdata{Innodb_data_writes}=$statRef->{Innodb_data_writes}->{value};
  $newdata{Innodb_data_reads}=$statRef->{Innodb_data_reads}->{value};
  $newdata{Innodb_log_writes}=$statRef->{Innodb_log_writes}->{value};
  $newdata{Innodb_data_fsyncs}=$statRef->{Innodb_data_fsyncs}->{value};
  $newdata{Innodb_os_log_fsyncs}=$statRef->{Innodb_os_log_fsyncs}->{value};
  $newdata{Innodb_row_lock_current_waits}=$statRef->{Innodb_row_lock_current_waits}->{value};
  $newdata{Innodb_row_lock_time}=$statRef->{Innodb_row_lock_time}->{value};
  $newdata{Innodb_buffer_pool_pages_data}=$statRef->{Innodb_buffer_pool_pages_data}->{value};
  $newdata{Innodb_buffer_pool_pages_free}=$statRef->{Innodb_buffer_pool_pages_free}->{value};
  $newdata{Innodb_buffer_pool_pages_flushed}=$statRef->{Innodb_buffer_pool_pages_flushed}->{value};
  $newdata{Innodb_buffer_pool_reads}=$statRef->{Innodb_buffer_pool_reads}->{value};
  $newdata{Innodb_dblwr_writes}=$statRef->{Innodb_dblwr_writes}->{value};
  $newdata{Innodb_pages_read}=$statRef->{Innodb_pages_read}->{value};
  $newdata{Innodb_pages_written}=$statRef->{Innodb_pages_written}->{value};

  $date=formatDateShort(time);

  my $load = `uptime |awk -F'average:' '{ print \$2}' | awk -F ',' '{ print \$1}'`;

  my $vmstat = `/usr/bin/vmstat 1 2 |tail -1`;
  chomp  $vmstat;
  $vmstat =~ s/^\s+//;
  $vmstat =~ s/\s+$//;
  my @each = split /\s+/,$vmstat;
  $runque = $each[0];
  $swpd = $each[2];
  $freeMem = $each[3]/1024;
  $si = $each[6];
  $so = $each[7];
# $bi = $each[8];
# $bo = $each[9];
  $userCPU = $each[12];
  $sysCPU = $each[13];
  $idleCPU = $each[14];
  $wa = $each[15];

  #get mysql rss memory usage
  my $info = `ps -ef | grep mysqld | grep -v 'grep mysqld' | grep -v mysqld_safe | awk '{print \$2}'`;
  chomp $info;
  $info =~ s/^\s+//;
  $info =~ s/\s+$//;
  my @pids = split /\s+/, $info;
  my $count = 0;
  my $len  = $#pids + 1;
  my $rss_mysql = 0;
  while($count < $len)
  {
        my $tmp = `ps -o rss $pids[$count] | tail -1`;
        $rss_mysql += $tmp;
        $count ++;
  }
  $dir = &findDir("show variables like 'innodb_log_group_home_dir'");
  my $logdir_dev = `df -h $dir | perl -pe 's/\\n//' | awk -F '/dev/' '{print \$2}' |  awk '{print \$1}'`;
  $dir = &findDir("show variables like 'innodb_data_home_dir'");
  my $innodb_data_dev = `df -h $dir | perl -pe 's/\\n//' | awk -F '/dev/' '{print \$2}' |  awk '{print \$1}'`;
  $dir = &findDir("show variables like 'datadir'");
  my $datadir_dev = `df -h  $dir | perl -pe 's/\\n//' | awk -F '/dev/' '{print \$2}' |  awk '{print \$1}'`;

  my $tmp = "$HOME/tmp_$$";
  `iostat -xm 1 2 | perl -pe 's/\\s+\\n//' > $tmp `;
  my $innodb_redo = `grep "$logdir_dev" $tmp | tail -1`;
  my $innodb_data = `grep "$innodb_data_dev" $tmp | tail -1`;
  my $datadir = `grep "$datadir_dev" $tmp | tail -1`;

  `rm $tmp`;

  chomp  $innodb_redo;
  $innodb_redo =~ s/^\s+//;
  $innodb_redo =~ s/\s+$//;
  my @list1 = split /\s+/,$innodb_redo;
  $svctm_log = $list1[10];      $svctm_log = 0 if(!$svctm_log);
  $util_log = $list1[11];       $util_log = 0 if(!$util_log);

  chomp $innodb_data;
  $innodb_data =~ s/^\s+//;
  $innodb_data =~ s/\s+$//;
  my @list2 = split /\s+/,$innodb_data;
  $svctm_innodb_data = $list2[10];      $svctm_innodb_data = 0 if(!$svctm_innodb_data);
  $util_innodb_data = $list2[11];       $util_innodb_data = 0 if(!$util_innodb_data);

  chomp $datadir;
  $datadir =~ s/^\s+//;
  $datadir =~ s/\s+$//;
  my @list3 = split /\s+/,$datadir;
  $svctm_datadir = $list3[10];  $svctm_datadir = 0 if(!$svctm_datadir);
  $util_datadir = $list3[11];   $util_datadir = 0 if(!$util_datadir);

  if (!%olddata) {
     %olddata=%newdata; #This is our first line, so use the same data for a baseline. This makes all deltas zero,
                        # instead of strange, large numbers.
  }

  # Print the data...mostly deltas, so subtract old data.
  printf MAIN_FILE "%s %6d %6d %6d %7d %6d  %6.2f %5d %7d %7d %7d %7d %8d %8d %6d %6d\n",$date,
     ($newdata{executions}-$olddata{executions}),
     ($newdata{selects}-$olddata{selects}),
     ($newdata{updates}-$olddata{updates}),
     ($newdata{inserts}-$olddata{inserts}),
     ($newdata{deletes}-$olddata{deletes}),
     $load,
     $newdata{logins}-$olddata{logins},
     $newdata{total_sessions},
     $newdata{active_sessions},
     $newdata{locks_waited}-$olddata{locks_waited},
     $newdata{locks_immediate}-$olddata{locks_immediate},
     $newdata{bytes_received}-$olddata{bytes_received},
     $newdata{bytes_sent}-$olddata{bytes_sent},
     $newdata{sort_rows}-$olddata{sort_rows},
     $slave;

  printf INNO_FILE "%s %6d %6d %6d %6d %5d %8d %8d  %8dM %8dM %8d %8d %8d %7d %6d\n",$date,
     ($newdata{Innodb_data_writes}-$olddata{Innodb_data_writes}),
     ($newdata{Innodb_data_reads}-$olddata{Innodb_data_reads}),
     ($newdata{Innodb_log_writes}-$olddata{Innodb_log_writes}),
     ($newdata{Innodb_data_fsyncs}-$olddata{Innodb_data_fsyncs}),
     ($newdata{Innodb_os_log_fsyncs}-$olddata{Innodb_os_log_fsyncs}),
     $newdata{Innodb_row_lock_current_waits}-$olddata{Innodb_row_lock_current_waits},
     $newdata{Innodb_row_lock_time}-$olddata{Innodb_row_lock_time},
     $newdata{Innodb_buffer_pool_pages_data}*16/1024,
     $newdata{Innodb_buffer_pool_pages_free}*16/1024,
     $newdata{Innodb_buffer_pool_pages_flushed}-$olddata{Innodb_buffer_pool_pages_flushed},
     $newdata{Innodb_buffer_pool_reads}-$olddata{Innodb_buffer_pool_reads},
     $newdata{Innodb_dblwr_writes}-$olddata{Innodb_dblwr_writes},
     $newdata{Innodb_pages_read}-$olddata{Innodb_pages_read},
     $newdata{Innodb_pages_written}-$olddata{Innodb_pages_written}
     ;

   printf SYS_FILE "%s %3dK %6dM %3dK/s %3dK/s %6dM %5.1f %5.1f %5.1f %5.1f %5.1f %7.2f  %7.2f %7.2f  %7.2f  %7.2f  %7.2f\n",
    $date,$swpd,$freeMem,$si,$so,$rss_mysql/1024,$runque,$userCPU,$sysCPU,$idleCPU,$wa,$svctm_log,$util_log,$svctm_innodb_data,$util_innodb_data,$svctm_datadir,$util_datadir;

  $cycleElapsed=time-$cycleStart;
  if ($cycleElapsed>$cycle_time) {
      print MAIN_FILE "WARNING: last cycle took $cycleElapsed seconds, longer than $cycle_time second interval\n" ;
  } else {
     sleep($cycle_time-$cycleElapsed);
  }
  $cycleStart=time;
  %olddata=%newdata; #Move current data to old data for next set of deltas.
}

sub open_output {
   if (fileno(MAIN_FILE)) {
       my @fs = stat(MAIN_FILE);
       if ($fs[7]>6000000) {
          close(MAIN_FILE);
          close(SYS_FILE);
          close(INNO_FILE);
          rename ("$outputFilenameMain.1","$outputFilenameMain.2");
          rename ("$outputFilenameMain","$outputFilenameMain.1");
          rename ("$outputFilenameSYS.1","$outputFilenameSYS.2");
          rename ("$outputFilenameSYS","$outputFilenameSYS.1");
          rename ("$outputFilenameInnoDB","$outputFilenameInnoDB.1");
          rename ("$outputFilenameInnoDB.1","$outputFilenameInnoDB.2");
       } else {
          return;
       }
   }
   open MAIN_FILE,">> $outputFilenameMain" or die "free_con: can't open output file $outputFilenameMain: $!\n";
   flock MAIN_FILE,6 or exit;
   open SYS_FILE,">> $outputFilenameSYS" or die "free_con: can't open output file $outputFilenameSYS: $!\n";
   open INNO_FILE,">> $outputFilenameInnoDB" or die "free_con: can't open output file $outputFilenameInnoDB: $!\n";

   my $oldfh = select(MAIN_FILE); $| = 1; select($oldfh);
   $oldfh = select(SYS_FILE); $| = 1; select($oldfh);
   $oldfh = select(INNO_FILE); $| = 1; select($oldfh);
}
sub formatDate {
    my $tmTime=shift;
    my ($sec,$min,$hour,$day,$mon,$year)=localtime($tmTime);
    my $dateStr=sprintf "%02d-%02d-%04d %02d:%02d:%02d",$day,$mon+1,$year+1900,$hour,$min,$sec;
    return ($dateStr);
}
sub formatDateShort {
    my $tmTime=shift;
    my ($sec,$min,$hour,$day,$mon,$year)=localtime($tmTime);
    my $dateStr=sprintf "%02d-%02d %02d:%02d:%02d",$mon+1,$day,$hour,$min,$sec;
    return ($dateStr);
    }
sub formatTime {
    my $tmTime=shift;
    my ($sec,$min,$hour,$day,$mon,$year)=localtime($tmTime);
    my $dateStr=sprintf "%02d:%02d:%02d.00",$hour,$min,$sec;
    return ($dateStr);
}

sub findDir {
        my ($sql) = @_;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        my ($var, $dir) = $sth->fetchrow_array();
        $sth->finish;
        return $dir;
}

sub get_root_pass {
  # ---------------------------------------------------------------------------------
  # Try to get the password from the sqlite table on batch.vip
  #
  # seley  11/14/12 If root password cannot be found from vip, find it via the host name instead
  # ---------------------------------------------------------------------------------
  my ($re, $password);
  my $tgthost = "dba.vip.ccc.com";
  my $col     = "admin_password";
  my $host    = `/bin/hostname --fqdn`;  chomp $host;
  my $mailwho = "rajesh\@ccc.com";
  my $where   = "host";
  my $what    = $host;

  $password = get("http://${tgthost}/cgi-bin/instanceCloud/getColumn?vip=$host&col=$col");
  $password =~ s/\n|\s+//g;         # Remove any newline characters or white space in password

  #print "get_root_pass results: $password\n" if $password ;
  if (! $password or $password =~ /Error=/i) {
    $password = get("http://${tgthost}/cgi-bin/instanceCloud/getColumn2?where=$where&what=$what&col=$col");
    $password =~ s/\n|\s+//g;         # Remove any newline characters or white space in password
    #print "get_root_pass results: $password\n" if $password;
    if (! $password or $password =~ /Error=/i) {
      $re = "my_con_innodb_linux-Error getting admin_password from batch.vip sqlite database_list!";
      #`/bin/mailx -s "$re" $mailwho < /dev/null`;
            exit;
    }
  }
  return($password);
}
