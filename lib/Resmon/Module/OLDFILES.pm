package Resmon::Module::OLDFILES;
use Resmon::ExtComm qw/cache_command/;
use vars qw/@ISA/;
@ISA = qw/Resmon::Module/;

# Checks for files in a directory older than a certain time
# Parameters:
#   minutes : how old can the files be before we alarm
#   checkmount : check to make sure the directory is mounted first
#                (only enable if the dir you are checking is the mountpoint of
#                a filesystem)
# Example:
#
# OLDFILES {
#   /test/dir : minutes => 5, checkmount => 1
#   /other/dir : minutes => 60
# }

sub handler {
    my $arg = shift;
    my $os = $arg->fresh_status();
    return $os if $os;
    my $dir = $arg->{'object'};
    my $minutes = $arg->{'minutes'};
    my $checkmount = $arg->{'checkmount'} || 0;

    # Check to make sure the directory is mounted first
    if ($checkmount) {
        my $output = cache_command("df -k", 600);
        my ($line) = grep(/$dir\s*/, split(/\n/, $output));
        if($line !~ /(\d+)%/) {
            return "BAD", "dir not mounted";
        }
    }

    # Then look for old files
    my $output = cache_command("find $dir -mmin +$minutes | wc -l", 600);
    chomp($output);
    if ($output == 0) {
        return "OK", "0 files over $minutes minutes";
    } else {
        return "BAD", "$output files over $minutes minutes";
    }
}

1;
