#!/usr/local/bin/perl -w

use strict;
use JSON;

while(<STDIN>) {
        chomp();
        if(/^\[(\S+\s+\S+\s+\d+\s+\d{2}:\d{2}:\d{2}\s+\d{4})\]\s+\[error\]\s+ywslog\?([\S+=\S*&]*\S+=\S*)$/) {
                print "START ENTRY **************************************\n";
                print "Date: " . decodeUrl($1) . "\n";
                for my $pair (split(/&/, $2)) {
                        my ($name, $value) = split(/=/, $pair);
                        $name = decodeUrl($name);
                        $value = decodeUrl($value);

                        if($name eq "object") {
                                $value =~ s/,\}/\}/g;
                                my $object = jsonToObj($value);
                                print objToJson($object, {pretty => 1, indent => 2});
                        }
                        else {
                                print "$name: $value\n";
                        }
                }
                print "END ENTRY ****************************************\n";
        }

        }
        elsif ( /^\[(\S+\s+\S+\s+\d+\s+\d{2}:\d{2}:\d{2}\s+\d{4})\]\s+\[error\]\s+PHP Fatal error(.*)/ ) {
            print "PHP ERROR **************************************\n";
            print "Date: " . decodeUrl($1) . "\n";
            print "message: " . $2 . "\n";
            print "END ERROR **************************************\n";
        }
}

exit 0;

sub decodeUrl {
        $_ = shift;
        tr/+/ /;
        s/\%([A-Fa-f0-9]{2})/pack('c', hex($1))/eg;
        return $_;
}

