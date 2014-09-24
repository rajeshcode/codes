#!/usr/bin/perl
#
# format.pl
# Format disks with ext4 > 2T . Create with 4T partition with parted 
#
# Version 2.0.0
#
# Simple script that  will find disks with no partitions and set them up hadoop style, one large partition.
# Defaults labels follow /hadoop01, /hadoop02, etc... naming convention.
# If fstab uses /hadoop/1, /hadoop/2, etc... script will use that convention
#

use strict;
use Getopt::Long;
use Data::Dumper;

sub formatDisk(){
   my($empty_disk, $label) = @_;
   my $device = '/dev/' . $empty_disk . '1';

   # Setup disk label
   print "Setting up disk label on /dev/$empty_disk:\n";
   if (system("parted --script /dev/$empty_disk mklabel gpt") == 0){
      print "Disk label successfully created.\n\n";
   }else{
      print "Disk label unsuccessfully created.\n";
      print "Skipping to next disk if any.\n\n";
      next;
   }

   # Setup partitioning
   print "Setting up partition on /dev/$empty_disk:\n";
   if(system("parted --script -- /dev/$empty_disk mkpart primary 1 -1") == 0){
      print "Partition successfully created.\n\n";
   }else{
      print "Partition unsuccessfully created.\n";
      print "Skipping to next disk if any\n\n";
      next;
   }

   system("sleep 5"); # Nap time...

   print "Formatting $device with label $label using";
   if(-e '/sbin/mkfs.ext4'){
      print " ext4:\n";
      if(system("mkfs.ext4 -L $label -N 61050880 -m 1 -O sparse_super $device") == 0){
         print "ext4 filesystem successfully created.\n\n";
      }else{
         print "ext4 filesystem unsuccessfully created.\n";
         print "Skipping to next disk if any\n\n";
         next;
      }
   }else{
      print " ext3:\n";
      if(system("mkfs.ext3 -j -L $label -N 61050880 -m 1 -O sparse_super $device") == 0){
         print "ext3 filesystem successfully created.\n\n";
      }else{
         print "ext3 filesystem unsuccessfully created.\n";
         print "Skipping to next disk if any\n\n";
         next;
      }
   }

   # tune2fs the device turning off count and interval checks
   print "tune2fs'ing $device:\n";
   if(system("tune2fs -c 0 -i 0 $device") == 0){
      print "tune2fs'ing successfully completed\n\n";
   }else{
      print "tune2fs'ing unsuccessfully completed\n";
      print "Skipping to next disk if any\n\n";
      next;
   }
}

sub getHelp(){
   my $usage = "This script will take all raw/new disks and hadoop-a-size them.\n\n" .
               "Usage:\n" .
               "   $0\n" .
               "   $0 --all\n" .
               "   $0 --help\n" .
               "   $0 --disk sdb --label /hadoop01\n" .
               "Options:\n" .
               "   --all: Delete all non-root partitions and (re)format.\n" .
               "        Note: Label style determined by fstab, else use /hadoop01 style\n" .
               "   --disk: Specify disk to format: ie sdb, sdc, sdd.\n" .
               "        Note: --all will be ignored\n" .
               "   --label: Specify label to use when formatting disk.\n" .
               "        Note: To be used in conjuction with --disk\n" .
               "Note:\n" .
               "   -If no option specified, it will go through find empty disks and format\n" .
               "    them according to LABELs used in /etc/fstab\n" .
               "   -If Parallel::ForkManager module exists format will be done in parallel fashion.\n" .
               "    Else, it will be done in serial.\n\n";
   return $usage;
}

# Check if Parallel::ForkManager package is available for parallelism
eval{
   require Parallel::ForkManager;
   Parallel::ForkManager->import();
};

# Will contain string saying not found if module is not found
my $fork_manager_not_found = $@;

my($all, $disk, $label, $help);
GetOptions('help' => \$help, 'all' => \$all, 'disk=s' => \$disk, 'label=s' => \$label) or die &getHelp();

die &getHelp() if($help);
die &getHelp() if(($disk and !$label) || (!$disk and $label));

if($disk and $label){
   &formatDisk($disk, $label);
   exit;
}

# Holds data about disks, such as blocks, label, etc...
my %part_info = ();

# Get all sd info from /proc/partitions
my @proc_partitions_sd = `cat /proc/partitions | grep ' sd'`;

# Remove all partitions NOT related to /
if($all){

   my $response = '';

   # Warn that it's dangerous and all data will be gone
   do{
      print "\nThis is a dangerous path you're taking.\n" .
            "Data will be lost and OS may lose operability.\n" .
            "Please ensure that the hadoop filesystems have been unmounted,before continuing...\n" .
            "\nAre you sure want to continue (yes/no)?: ";
      $response = lc(<STDIN>);
      $response =~ s/^\s+//g;
      $response =~ s/\s+$//g;

      print $response . "\n";

      print "\n";
   } until($response =~ /^yes$|^no$/);
 
   die "I'm scared too... Let's get out of here...\n\n" if $response =~ /^no$/;
   print "You're a brave soul... Let's do it...\n\n";
   system("sleep 5"); # Nap time...

   my $root_line = `df -h / | grep /`;
   chomp($root_line);
   $root_line =~ s/^\s+//g;
   $root_line =~ s/s+$//g;

   my($root_part, undef) = split(/\s+/, $root_line);

   $root_part =~ /\/dev\/(\w+)\d+/;
   my $root_disk = $1;

   my @proc_disks = grep(!/sd\w+\d+$/, grep(!/$root_disk/, @proc_partitions_sd));

   foreach my $proc_disk_line (@proc_disks){
      $proc_disk_line =~ s/^\s+//g;
      $proc_disk_line =~ s/\s+$//g;
      chomp($proc_disk_line);

      my($major, $minor, $blocks, $name) = split(/\s+/, $proc_disk_line);
      my @mtab = `cat /etc/mtab`;

      print "Unmounting /dev/${name}1.\n";

      if(system("umount /dev/${name}1") == 0){
         print "Unmounted /dev/${name}1.\n";
      }

      print "Deleting partition 1 on /dev/$name.\n";
      system("parted --script -- /dev/$name rm 1");
   }

   # Re-populate @proc_partitions_sd as it could have changed
   @proc_partitions_sd = `cat /proc/partitions | grep ' sd'`;
}



# Gather partition data and populate %part_info
foreach my $proc_part_line (@proc_partitions_sd) {
   $proc_part_line =~ s/^\s+//g;
   $proc_part_line =~ s/\s+$//g;
   chomp($proc_part_line);

   my($major, $minor, $blocks, $name) = split(/\s+/, $proc_part_line);

   if($name =~ /^(sd[a-z]+)\d+$/){
      my $parent_dev = $1;

      # Get blkid info from partition
      # Sample output of blkid
      # /dev/sdc1: LABEL="/hadoop07" UUID="f531bb83-ae75-477f-8bbc-fda53fd8d936" TYPE="ext4"
      my $blkid_info = `blkid -c /dev/null /dev/$name`;
      chomp($blkid_info);

      my @blkid_info_fields = split(/\s+/, $blkid_info);

      foreach my $field(@blkid_info_fields){
         if($field =~ /^LABEL/){
            $field =~ s/^LABEL="//;
            $field =~ s/"$//;
            $part_info{$parent_dev}{'parts'}{$name}{'label'} = $field;
            next;
         }

         if($field =~ /^TYPE/){
            $field =~ s/^TYPE="//;
            $field =~ s/"$//;
            $part_info{$parent_dev}{'parts'}{$name}{'type'} = $field;
            next;
         }

         if($field =~ /^UUID/){
            $field =~ s/^UUID"//;
            $field =~ s/"$//;
            $part_info{$parent_dev}{'parts'}{$name}{'uuid'} = $field;
            next;
         }
      }

      $part_info{$parent_dev}{'parts'}{$name}{'major'} = $major;
      $part_info{$parent_dev}{'parts'}{$name}{'minor'} = $minor;
      $part_info{$parent_dev}{'parts'}{$name}{'blocks'} = $blocks;

   }else{
      $part_info{$name}{'major'} = $major;
      $part_info{$name}{'minor'} = $minor;
      $part_info{$name}{'blocks'} = $blocks;
   }
}

# Used to get used labels and empty disks
my %used_labels = ();
my @empty_disks = ();
my @empty_disks_and_labels_to_use = ();

# Get labels and disks with no partitions
foreach my $disk (sort keys %part_info){
   if(scalar($part_info{$disk}{'parts'}) == 0){
      push(@empty_disks, $disk);
      next;
   }

   foreach my $part (keys %{$part_info{$disk}{'parts'}}){
      my $label = $part_info{$disk}{'parts'}{$part}{'label'};
      $used_labels{$label} = undef;
   }
}

# Determine Hadoopness Style of labels
# Label - /hadoop01
# Label - /hadoop/1

# Hadoop Style based on /etc/fstab
# Default is traditional
# Label - /hadoop01
my $ctr = '01';
my $hadoopness = '/hadoop';
my @fstab = `cat /etc/fstab`;

if(grep(/LABEL=\/hadoop\/\d+/, @fstab)){
   $ctr = '1';
   $hadoopness = '/hadoop/';
}

# Go through list of empty disks and format them hadoop style
foreach my $empty_disk (@empty_disks){
   # Find unused labels
   while(exists $used_labels{$hadoopness . $ctr}){
      $ctr++;
   }

   # Add label into %used_labels so it doesn't get used
   $used_labels{$hadoopness . $ctr} = undef;

   push(@empty_disks_and_labels_to_use, ["$empty_disk", "$hadoopness$ctr"]);
}

# If fork_manager not found format in serial fashion
if($fork_manager_not_found){
   print "$fork_manager_not_found\n";
   print "Format in serial fashion.  This may take awhile.\n\n";

   foreach my $hadoop_the_disk (@empty_disks_and_labels_to_use){
      my($empty_disk, $label) = @$hadoop_the_disk;
      &formatDisk($empty_disk, $label);
   }
}
else{
   print "Format in parallel fashion.\n\n";

   my $pm = new Parallel::ForkManager(12);

   foreach my $hadoop_the_disk (@empty_disks_and_labels_to_use){
      $pm->start and next;

      my($empty_disk, $label) = @$hadoop_the_disk;
      &formatDisk($empty_disk, $label);

      $pm->finish;
   }

   $pm->wait_all_children;
}

print "Okay done...\n\n";
