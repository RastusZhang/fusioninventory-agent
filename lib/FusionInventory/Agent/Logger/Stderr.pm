package FusionInventory::Agent::Logger::Stderr;

use strict;
use warnings;
use base 'FusionInventory::Agent::Logger';

use English qw(-no_match_vars);

sub new {
    my ($class, %params) = @_;

    my $self = $class->SUPER::new(%params);

    $self->{color} = $params{color};

    return $self;
}

sub _log {
    my ($self, %params) = @_;

    my $level = $params{level} || 'info';
    my $message = $params{message};
    return unless $message;

    chomp $message;

    my $format;
    if ($self->{color}) {
        if ($level eq 'warning') {
            $format = "\033[1;35m[%s] %s\033[0m\n";
        } elsif ($level eq 'error') {
            $format = "\033[1;31m[%s] %s\033[0m\n";
        } elsif ($level eq 'info') {
            $format = "\033[1;34m[%s]\033[0m %s\n";
        } elsif ($level =~ /^debug/ ) {
            $format = "\033[1;1m[%s]\033[0m %s\n";
        }
    } else {
        $format = "[%s] %s\n";
    }

    printf STDERR $format, $level, $message;

}

1;
__END__

=head1 NAME

FusionInventory::Agent::Logger::Stderr - A stderr backend for the logger

=head1 DESCRIPTION

This is a stderr-based backend for the logger. It supports coloring based on
message level on Unix platforms.
