#!/usr/bin/perl

use strict;
use warnings;


my $FLAG=0;
my $status=0;

sub header {

        print "\n\tCHECK FILESYSTEM\n";
        print "---------------------------------------------------\n";
        printf '%-10s|',"PARTITION";
        printf '%-10s|',"USED";
        printf '%-10s|',"SIZE";
        printf '%-3s',"USED %";
        print "\n";
        print "---------------------------------------------------\n";

}

sub footer {

        print "\n";
        print "---------------------------------------------------\n";

}

sub format {

        my ($PARTITIONf,$USEDf,$SIZEf,$USEDpf,$flagf) = @_;

        if ( $flagf == 1 ) {

                $flagf = "<--- PASSED THE LIMIT" ;

        }
        else
        {
                $flagf = "" ;

        }
                printf '%-10s|',$PARTITIONf ;
                printf '%-10s|',$USEDf ;
                printf '%-10s|',$SIZEf ;
                printf '%-3s',$USEDpf ;
                printf '%-3s',$flagf ;
                print "\n" ;

}

my @DF=`df -Ph |grep -v Filesystem`;

&header;

foreach my $DF ( @DF ) {

        my ($device,$SIZE,$used,$available,$usedpercentage,$PARTITION) = split (/ +/, $DF);

        $usedpercentage =~ s/\%//g;
        chomp($PARTITION);

        if ( $usedpercentage >= 85 ) {

                $FLAG=1;
                &format($PARTITION,$used,$SIZE,$usedpercentage,$FLAG);
                $status = 1;

         }
         else
        {

                $FLAG=0;
                &format($PARTITION,$used,$SIZE,$usedpercentage,$FLAG);

        }

}

&footer;

if ( $status == 1 ) {


        exit 1;
}
 else
{
        exit 0;
}


