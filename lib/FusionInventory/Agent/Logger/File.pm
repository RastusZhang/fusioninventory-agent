package FusionInventory::Agent::Logger::File;

use strict;
use warnings;
use base 'FusionInventory::Agent::Logger';

use English qw(-no_match_vars);
use Fcntl qw(:flock);
use File::stat;

sub new {
    my ($class, %params) = @_;

    my $self = $class->SUPER::new(%params);

    $self->{logfile}         = $params{logfile},
    $self->{logfile_maxsize} = $params{logfile_maxsize} ?
        $params{logfile_maxsize} * 1024 * 1024 : 0;

    return $self;
}

sub _log {
    my ($self, %params) = @_;

    my $level = $params{level} || 'info';
    my $message = $params{message};
    return unless $message;

    chomp $message;

    my $handle;
    if ($self->{logfile_maxsize}) {
        my $stat = stat($self->{logfile});
        if ($stat && $stat->size() > $self->{logfile_maxsize}) {
            if (!open $handle, '>', $self->{logfile}) {
                warn "Can't open $self->{logfile}: $ERRNO";
                return;
            }
        }
    }

    if (!$handle && !open $handle, '>>', $self->{logfile}) {
        warn "can't open $self->{logfile}: $ERRNO";
        return;
    }

    my $locked;
    my $retryTill = time + 60;

    while ($retryTill > time && !$locked) {
        ## no critic (ProhibitBitwise)
        # get an exclusive lock on log file
        $locked = 1 if flock($handle, LOCK_EX|LOCK_NB);
    }

    if (!$locked) {
        die "can't get an exclusive lock on $self->{logfile}: $ERRNO";
    }

    print {$handle}
        "[". localtime() ."]" .
        "[$level]" .
        " $message\n";

    # closing handle release the lock automatically
    close $handle;

}

1;
__END__

=head1 NAME

FusionInventory::Agent::Logger::File - A file backend for the logger

=head1 DESCRIPTION

This is a file-based backend for the logger. It supports automatic filesize
limitation.
