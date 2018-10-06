#
# Copyright (c) 2003-2015 University of Chicago and Fellowship
# for Interpretations of Genomes. All Rights Reserved.
#
# This file is part of the SEED Toolkit.
#
# The SEED Toolkit is free software. You can redistribute
# it and/or modify it under the terms of the SEED Toolkit
# Public License.
#
# You should have received a copy of the SEED Toolkit Public License
# along with this program; if not write to the University of Chicago
# at info@ci.uchicago.edu or the Fellowship for Interpretation of
# Genomes at veronika@thefig.info or download a copy from
# http://www.theseed.org/LICENSE.TXT.
#

#
# This is a SAS component.
#

package RoleParse;

    use strict;
    use warnings;
    use Digest::MD5;
    use Encode qw(encode_utf8);

=head1 Role Parser

This package contains the methods for parsing, normalizing, and computing the checksum of roles.

=cut

=head3 EC_PATTERN

    $string =~ /$RoleParse::EC_PATTERN/;

Pre-compiled pattern for matching EC numbers.

=cut

    our $EC_PATTERN = qr/\(\s*E\.?C\.?(?:\s+|:)(\d\.(?:\d+|-)\.(?:\d+|-)\.(?:n?\d+|-))\s*\)/;

=head3 TC_PATTERN

    $string =~ /$RoleParse::TC_PATTERN/;

Pre-compiled pattern for matchin TC numbers.

=cut

    our $TC_PATTERN = qr/\(\s*T\.?C\.?(?:\s+|:)(\d\.[A-Z]\.(?:\d+|-)\.(?:\d+|-)\.(?:\d+|-)\s*)\)/;

=head3 Parse

    my ($roleText, $ecNum, $tcNum, $hypo) = RoleParse::Parse($role);

Parse a role. The EC and TC numbers are extracted and an attempt is made to determine if the role is
hypothetical.

=over 4

=item role

Text of the role to parse.

=item RETURN

Returns a four-element list consisting of the main role text, the EC number (if any),
the TC number (if any), and a flag that is TRUE if the role is hypothetical and FALSE
otherwise.

=back

=cut

sub Parse {
    # Convert from the instance form of the call to a direct call.
    shift if UNIVERSAL::isa($_[0], __PACKAGE__);
    # Get the parameters.
    my ($role) = @_;
    # Extract the EC number.
    my ($ecNum, $tcNum) = ("", "");
    my $roleText = $role;
    if ($role =~ /(.+?)\s*$EC_PATTERN\s*(.*)/) {
        $roleText = TextJoin($1, $3);
        $ecNum = $2;
    } elsif ($role =~ /(.+?)\s*$TC_PATTERN\s*(.*)/) {
        $roleText = TextJoin($1, $3);
        $tcNum = $2;
    }
    # Fix spelling problems.
    $roleText = FixupRole($roleText);
    # Check for a hypothetical.
    my $hypo = SeedUtils::hypo($roleText);
    # If this is a hypothetical with a number, change it.
    if ($roleText eq 'hypothetical protein' || ! $roleText) {
        if ($ecNum) {
            $roleText = "putative protein $ecNum";
        } elsif ($tcNum) {
            $roleText = "putative transporter $tcNum";
        }
    }
    # Return the parse results.
    return ($roleText, $ecNum, $tcNum, $hypo);
}

=head3 Normalize

    my $normalRole = RoleParse::Normalize($role);

Normalize the text of a role by removing extra spaces and converting it to lower case.

=over 4

=item role

Role text to normalize. This should be taken from the output of L</Parse>.

=item RETURN

Returns a normalized form of the role.

=back

=cut

sub Normalize {
    # Get the parameters.
    my ($role) = @_;
    # Remove the extra spaces and punctuation.
    $role =~ s/[\s,.:]{2,}/ /g;
    # Translate unusual white characters.
    $role =~ s/\s/ /;
    # Convert to lower case.
    my $retVal = lc $role;
    # Return the result.
    return $retVal;
}

=head3 Checksum

    my $checksum = RoleParse::Checksum($role);

Return the checksum for the incoming role text. The role is normalized and fixed up, then the checksum
is computed. This value can be checked against the database to find the role ID.

=over 4

=item role

Text (description) of the role to check.

=item RETURN

Returns the MD5 checksum of the role.

=back

=cut

sub Checksum {
    my ($role) = @_;
    my ($roleText) = Parse($role);
    my $normalized = Normalize($roleText);
    my $encoded = encode_utf8($normalized);
    my $retVal = Digest::MD5::md5_base64($encoded);
    return $retVal;
}


=head3 FixupRole

    my $roleText = RoleParse::FixupRole($role);

Perform basic fixups on the text of a role. This method is intended for internal use, and it performs
spelling-type normalizations required both when computing a role's checksum or formatting the role
for storage.

=over 4

=item role

The text of a role.

=item RETURN

Returns the fixed-up text of a role.

=back

=cut

sub FixupRole {
    my ($retVal) = @_;
    # Fix spelling mistakes.
    $retVal =~ s/^\d{7}[a-z]\d{2}rik\b|\b(?:hyphothetical|hyothetical)\b/hypothetical/ig;
    # Trim spaces;
    $retVal =~ s/\r/ /g;
    $retVal =~ s/^\s+//;
    $retVal =~ s/\s+$//;
    # Remove quoting.
    $retVal =~ s/^"//;
    $retVal =~ s/"$//;
    # Fix extra spaces.
    $retVal =~ s/\s+/ /g;
    # Return the fixed-up role.
    return $retVal;
}

=head3 TextJoin

    my $string = RoleParse::TextJoin(@phrases);

Concatenate phrases to produce text. If the second phrase begins with a separator, it will be
joined directly. Otherwise, it will be joined with a space.

=over 4

=item phrases

A list of phrases to join.

=item RETURN

Returns a string containing all the phrases joined together.

=back

=cut

sub TextJoin {
    my (@phrases) = @_;
    # Start with the first phrase.
    my $retVal = shift @phrases;
    # Loop through the rest.
    for my $phrase (@phrases) {
        if ($phrase =~ /^[,\.;:]/) {
            $retVal .= $phrase;
        } else {
            $retVal .= " $phrase";
        }
    }
    # Return the result.
    return $retVal;
}



1;
