#!/usr/bin/perl



sub sendEmail
{

my ($to, $from, $subject, @message) = @_;
my $sendmail = '/usr/lib/sendmail';

        unless(open(MAIL, "|$sendmail -oi -t"))
        {
                return 0;
        }
        else
        {
                print MAIL "From: $from\n";
                print MAIL "To: $to\n";
                print MAIL "Subject: $subject\n\n";
                print MAIL "@message\n";

                close(MAIL);
        }

}

return 1;

