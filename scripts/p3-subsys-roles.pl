=head1 Create Subsystem Role File

    p3-subsys-roles.pl [options]

Create a subsystem role file for L<p3-function-to-role.pl>.  The file will be created on the standard output.  It will be headerless and
tab-delimited, with three columns: (0) the role ID, (1)  the role checksum, and (2) the role name.

=head2 Parameters

The are no positional parameters.

The following command-line options are supported.

=over 4

=item verbose

If specified, progress messages will be written to STDERR.

=back

=cut

use strict;
use P3DataAPI;
use P3Utils;
use RoleParse;


# Get the command-line options.
my $opt = P3Utils::script_opts('',
        ['verbose|debug|v', 'display progress messages on STDERR']
        );
my $debug = $opt->verbose;
# Get access to PATRIC.
my $p3 = P3DataAPI->new();
# This hash will hold the role checksums.  Each checksum is mapped to an ID, checksum, and name.
my %hash;
# Get all the subsystem roles from the subsystems.
my $idNum = 0;
print STDERR "Retrieving subsystem roles.\n" if $debug;
my $results = P3Utils::get_data($p3, subsystem => [['ne', 'subsystem_id', 'x']], ['role_name']);
for my $result (@$results) {
    my ($roles) = @$result;
    for my $role (@$roles) {
        my $checksum = RoleParse::Checksum($role);
        if (! $hash{$checksum}) {
            $idNum++;
            $hash{$checksum} = [$idNum, $checksum, $role];
        }
    }
}
print STDERR "Writing output.\n" if $debug;
for my $checksum (sort keys %hash) {
    my $roleData = $hash{$checksum};
    P3Utils::print_cols($roleData);
}
