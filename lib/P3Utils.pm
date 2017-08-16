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

# This is a SAS Component

package P3Utils;

    use strict;
    use warnings;
    use Getopt::Long::Descriptive;
    use Data::Dumper;
    use LWP::UserAgent;
    use HTTP::Request;
    use SeedUtils;
    use Digest::MD5;

=head1 PATRIC Script Utilities

This module contains shared utilities for PATRIC 3 scripts.

=head2 Constants

These constants define the sort-of ER model for PATRIC.

=head3 OBJECTS

Mapping from user-friendly names to PATRIC names.

=cut

use constant OBJECTS => {   genome => 'genome',
                            feature => 'genome_feature',
                            family => 'protein_family_ref',
                            genome_drug => 'genome_amr',
                            contig =>  'genome_sequence',
                            drug => 'antibiotics', };

=head3 FIELDS

Mapping from user-friendly object names to default fields.

=cut

use constant FIELDS =>  {   genome => ['genome_name', 'genome_id', 'genome_status', 'sequences', 'patric_cds', 'isolation_country', 'host_name', 'disease', 'collection_year', 'completion_date'],
                            feature => ['patric_id', 'refseq_locus_tag', 'gene_id', 'plfam_id', 'pgfam_id', 'product'],
                            family => ['family_id', 'family_type', 'family_product'],
                            genome_drug => ['genome_id', 'antibiotic', 'resistant_phenotype'],
                            contig => ['genome_id', 'accession', 'length', 'gc_content', 'sequence_type', 'topology'],
                            drug => ['cas_id', 'antibiotic_name', 'canonical_smiles'], };

=head3 IDCOL

Mapping from user-friendly object names to ID column names.

=cut

use constant IDCOL =>   {   genome => 'genome_id',
                            feature => 'patric_id',
                            family => 'family_id',
                            genome_drug => 'id',
                            contig => 'sequence_id',
                            drug => 'antibiotic_name' };

=head3 DERIVED

Mapping from objects to derived fields. For each derived field name we have a list reference consisting of the function name followed by a list of the
constituent fields.

=cut

use constant DERIVED => {
            genome =>   {   taxonomy => ['concatSemi', 'taxon_lineage_names'],
                        },
            feature =>  {   function => ['altName', 'product'],
                        },
            family =>   {
                        },
            genome_drug => {
                        },
            contig =>   {   md5 => ['md5', 'sequence'],
                        },
            drug =>     {
                        },
};
=head2  Methods

=head3 data_options

    my @opts = P3Utils::data_options();

This method returns a list of the L<Getopt::Long::Descriptive> specifications for the common data retrieval
options. These options include L</delim_options> plus the following.

=over 4

=item attr

Names of the fields to return. Multiple field names may be specified by coding the option multiple times or
separating the field names with commas.  Mutually exclusive with C<--count>.

=item count

If specified, a count of records found will be returned instead of the records themselves. Mutually exclusive with C<--attr>.

=item equal

Equality constraints of the form I<field-name>C<,>I<value>. If the field is numeric, the constraint will be an
exact match. If the field is a string, the constraint will be a substring match. An asterisk in string values
is interpreted as a wild card. Multiple equality constraints may be specified by coding the option multiple
times.

=item lt, le, gt, ge

Inequality constraints of the form I<field-name>C<,>I<value>. Multiple constrains of each type may be specified
by coding the option multiple times.

=item in

Multi-valued equality constraints of the form I<field-name>C<,>I<value1>C<,>I<value2>C<,>I<...>C<,>I<valueN>.
The constraint is satisfied if the field value matches any one of the specified constraint values. Multiple
constraints may be specified by coding the option multiple times.

=item required

Specifies the name of a field that must have a value for the record to be included in the output. Multiple
fields may be specified by coding the option multiple times.

=back

=cut

sub data_options {
    return (['attr|a=s@', 'field(s) to return'],
            ['count|K', 'if specified, a count of records returned will be displayed instead of the records themselves'],
            ['equal|eq|e=s@', 'search constraint(s) in the form field_name,value'],
            ['lt=s@', 'less-than search constraint(s) in the form field_name,value'],
            ['le=s@', 'less-or-equal search constraint(s) in the form field_name,value'],
            ['gt=s@', 'greater-than search constraint(s) in the form field_name,value'],
            ['ge=s@', 'greater-or-equal search constraint(s) in the form field_name,value'],
            ['in=s@', 'any-value search constraint(s) in the form field_name,value1,value2,...,valueN'],
            ['required|r=s@', 'field(s) required to have values'],
            delim_options());
}

=head3 col_options

    my @opts = P3Utils::col_options();

This method returns a list of the L<Getopt::Long::Descriptive> specifications for the common column specification
options. These options are as follows.

=over 4

=item col

Index (1-based) of the column number to contain the key field. If a non-numeric value is specified, it is presumed
to be the value of the header in the desired column. This option is only present if the B<$colFlag> parameter is
TRUE. The default is C<0>, which indicates the last column.

=item batchSize

Maximum number of lines to read in a batch. The default is C<100>. This option is only present if the B<$colFlag>
parameter is TRUE.

=item nohead

Input file has no headers.

=back

=cut

sub col_options {
    return (['col|c=s', 'column number (1-based) or name', { default => 0 }],
                ['batchSize|b=i', 'input batch size', { default => 100 }],
                ['nohead', 'file has no headers']);
}

=head3 delim_options

    my @options = P3Utils::delim_options();

This method returns a list of options related to delimiter specification for multi-valued fields.

=over 4

=item delim

The delimiter to use between object names. The default is C<::>. Specify C<tab> for tab-delimited output, C<space> for
space-delimited output, C<semi> for a semicolon followed by a space, or C<comma> for comma-delimited output.
Other values might have unexpected results.

=back

=cut

sub delim_options {
    return (['delim=s', 'delimiter to place between object names', { default => '::' }],
    );
}

=head3 delim

    my $delim = P3Utils::delim($opt);

Return the delimiter to use between the elements of multi-valued fields.

=over 4

=item opt

A L<Getopts::Long::Descriptive::Opts> object containing the delimiter specification.

=back

=cut

use constant DELIMS => { space => ' ', tab => "\t", comma => ',', '::' => '::', semi => '; ' };

sub delim {
    my ($opt) = @_;
    my $retVal = DELIMS->{$opt->delim} // $opt->delim;
    return $retVal;
}

=head3 undelim

    my $undelim = P3Utils::undelim($opt);

Return the pattern to use to split the elements of multi-valued fields.

=over 4

=item opt

A L<Getopts::Long::Descriptive::Opts> object containing the delimiter specification.

=back

=cut

use constant UNDELIMS => { space => ' ', tab => '\t', comma => ',', '::' => '::', semi => '; ' };

sub undelim {
    my ($opt) = @_;
    my $retVal = UNDELIMS->{$opt->delim} // $opt->delim;
    return $retVal;
}

=head3 get_couplets

    my $couplets = P3Utils::get_couplets($ih, $colNum, $opt);

Read a chunk of data from a tab-delimited input file and return couplets. A couplet is a 2-tuple consisting of a
key column followed by a reference to a list containing all the columns. The maximum number of couplets returned
is determined by the batch size. If the input file is empty, an undefined value will be returned.

=over 4

=item ih

Open input file handle for the tab-delimited input file.

=item colNum

Index of the key column.

=item opt

A L<Getopts::Long::Descriptive::Opts> object containing the batch size specification.

=item RETURN

Returns a reference to a list of couplets.

=back

=cut

sub get_couplets {
    my ($ih, $colNum, $opt) = @_;
    # Declare the return variable.
    my $retVal;
    # Only proceed if we are not at end-of-file.
    if (! eof $ih) {
        # Compute the batch size.
        my $batchSize = $opt->batchsize;
        # Initialize the return value to an empty list.
        $retVal = [];
        # This will count the records kept.
        my $count = 0;
        # Loop through the input.
        while (! eof $ih && $count < $batchSize) {
            # Read the next line.
            my $line = <$ih>;
            # Split the line into fields.
            my @fields = get_fields($line);
            # Extract the key column.
            my $key = $fields[$colNum];
            # Store the couplet.
            push @$retVal, [$key, \@fields];
            # Count this record.
            $count++;
        }
    }
    # Return the result.
    return $retVal;
}

=head3 get_col

    my $column = P3Utils::get_col($ih, $colNum);

Read an entire column of data from a tab-delimited input file.

=over 4

=item ih

Open input file handle for the tab-delimited input file, positioned after the headers.

=item colNum

Index of the key column.

=item RETURN

Returns a reference to a list of column values.

=back

=cut

sub get_col {
    my ($ih, $colNum) = @_;
    # Declare the return variable.
    my @retVal;
    # Loop through the input.
    while (! eof $ih) {
        # Read the next line.
        my $line = <$ih>;
        # Split the line into fields.
        my @fields = get_fields($line);
        # Extract the key column.
        push @retVal, $fields[$colNum];
    }
    # Return the result.
    return \@retVal;
}

=head3 process_headers

    my ($outHeaders, $keyCol) = P3Utils::process_headers($ih, $opt, $keyless);

Read the header line from a tab-delimited input, format the output headers and compute the index of the key column.

=over 4

=item ih

Open input file handle.

=item opt

Should be a L<Getopts::Long::Descriptive::Opts> object containing the specifications for the key
column or a string containing the key column name. At a minimum, it must support the C<nohead> option.

=item keyless (optional)

If TRUE, then it is presumed there is no key column.

=item RETURN

Returns a two-element list consisting of a reference to a list of the header values and the 0-based index of the key
column. If there is no key column, the second element of the list will be undefined.

=back

=cut

sub process_headers {
    my ($ih, $opt, $keyless) = @_;
    # Read the header line.
    my $line;
    if ($opt->nohead) {
        $line = '';
    } else {
        $line = <$ih>;
        die "Input file is empty.\n" if (! defined $line);
    }
    # Split the line into fields.
    my @outHeaders = get_fields($line);
    # This will contain the key column number.
    my $keyCol;
    # Search for the key column.
    if (! $keyless) {
        $keyCol = find_column($opt->col, \@outHeaders);
    }
    # Return the results.
    return (\@outHeaders, $keyCol);
}

=head3 find_column

    my $keyCol = P3Utils::find_column($col, \@headers);

Determine the correct (0-based) index of the key column in a file from a column specifier and the headers.
The column specifier can be a 1-based index or the name of a header.

=over 4

=item col

Incoming column specifier.

=item headers

Reference to a list of column header names.

=item RETURN

Returns the 0-based index of the key column.

=back

=cut

sub find_column {
    my ($col, $headers) = @_;
    my $retVal;
    if ($col =~ /^\-?\d+$/) {
        # Here we have a column number.
        $retVal = $col - 1;
    } else {
        # Here we have a header name.
        my $n = scalar @$headers;
        for ($retVal = 0; $retVal < $n && $headers->[$retVal] ne $col; $retVal++) {};
        # If our quick search failed, check for a match past the dot.
        if ($retVal >= $n) {
            undef $retVal;
            for (my $i = 0; $i < $n && ! $retVal; $i++) {
                if ($headers->[$i] =~ /\.(.+)$/ && $1 eq $col) {
                    $retVal = $i;
                }
            }
            if (! defined $retVal) {
                die "\"$col\" not found in headers.";
            }
        }
    }
    return $retVal;

}

=head3 form_filter

    my $filterList = P3Utils::form_filter($opt);

Compute the filter list for the specified options.

=over 4

=item opt

A L<Getopt::Long::Descriptive::Opts> object containing the command-line options that constrain the query (C<--equal>, C<--in>).

=item RETURN

Returns a reference to a list of filter specifications for a call to L<P3DataAPI/query>.

=back

=cut

sub form_filter {
    my ($opt) = @_;
    # This will be the return list.
    my @retVal;
    # Get the relational operator constraints.
    my %opHash = ('eq' => ($opt->equal // []),
                  'lt' => ($opt->lt // []),
                  'le' => ($opt->le // []),
                  'gt' => ($opt->gt // []),
                  'ge' => ($opt->ge // []));
    # Loop through them.
    for my $op (keys %opHash) {
        for my $opSpec (@{$opHash{$op}}) {
            # Get the field name and value.
            my ($field, $value);
            if ($opSpec =~ /(\w+),(.+)/) {
                ($field, $value) = ($1, clean_value($2));
            } else {
                die "Invalid --$op specification $opSpec.";
            }
            # Apply the constraint.
            push @retVal, [$op, $field, $value];
        }
    }
    # Get the inclusion constraints.
    my $inList = $opt->in // [];
    for my $inSpec (@$inList) {
        # Get the field name and values.
        my ($field, @values) = split /,/, $inSpec;
        # Validate the field name.
        die "Invalid field name \"$field\" for in-specification." if ($field =~ /\W/);
        # Clean the values.
        @values = map { clean_value($_) } @values;
        # Apply the constraint.
        push @retVal, ['in', $field, '(', join(',', @values) . ')'];
    }
    # Get the requirement constraints.
    my $reqList = $opt->required // [];
    for my $field (@$reqList) {
        # Validate the field name.
        die "Invalid field name \"$field\" for required-specification." if ($field =~ /\W+/);
        # Apply the constraint.
        push @retVal, ['eq', $field, '*'];
    }
    # Return the filter clauses.
    return \@retVal;
}

=head3 select_clause

    my ($selectList, $newHeaders) = P3Utils::select_clause($object, $opt, $idFlag);

Determine the list of fields to be returned for the current query. If an C<--attr> option is present, its
listed fields are used. Otherwise, a default list is used.

=over 4

=item object

Name of the object being retrieved-- C<genome>, C<feature>, C<protein_family>, or C<genome_drug>.

=item opt

L<Getopt::Long::Descriptive::Opts> object for the command-line options, including the C<--attr> option.

=item idFlag

If TRUE, then only the ID column will be specified if no attributes are explicitly specified. and if attributes are
explicitly specified, the ID column will be added if it is not present.

=item RETURN

Returns a two-element list consisting of a reference to a list of the names of the
fields to retrieve, and a reference to a list of the proposed headers for the new columns. If the user wants a
count, the first element will be undefined, and the second will be a singleton list of C<count>.

=back

=cut

sub select_clause {
    my ($object, $opt, $idFlag) = @_;
    # Validate the object.
    my $realName = OBJECTS->{$object};
    die "Invalid object $object." if (! $realName);
    # Get the attribute option.
    my $attrList = $opt->attr;
    if ($opt->count) {
        # Here the user wants a count, not data.
        if ($attrList) {
            die "Cannot specify both --attr and --count.";
        } else {
            # Just return a count header.
            $attrList = ['count'];
        }
    } elsif (! $attrList) {
        if ($idFlag) {
            $attrList = [IDCOL->{$object}];
        } else {
            $attrList = FIELDS->{$object};
        }
    } else {
        # Handle comma-splicing.
        $attrList = [ map { split /,/, $_ } @$attrList ];
        # If we need an ID field, be sure it's in there.
        if ($idFlag) {
            my $idCol = IDCOL->{$object};
            if (! scalar(grep { $_ eq $idCol } @$attrList)) {
                unshift @$attrList, $idCol;
            }
        }
    }
    # Form the header list.
    my @headers = map { "$object.$_" } @$attrList;
    # Clear the attribute list if we are counting.
    if ($opt->count) {
        undef $attrList;
    }
    # Return the results.
    return ($attrList, \@headers);
}

=head3 clean_value

    my $cleaned = P3Utils::clean_value($value);

Clean up a value for use in a filter specification.

=over 4

=item value

Value to clean up. Cleaning involves removing parentheses and leading and trailing spaces.

=item RETURN

Returns a usable version of the incoming value.

=back

=cut

sub clean_value {
    my ($value) = @_;
    $value =~ tr/()/  /;
    $value =~ s/\s+/ /g;
    $value =~ s/^\s+//;
    $value =~ s/\s+$//;
    return $value;
}


=head3 get_data

    my $resultList = P3Utils::get_data($p3, $object, \@filter, \@cols, $fieldName, \@couplets);

Return all of the indicated fields for the indicated entity (object) with the specified constraints.
It should be noted that this method is simply a less-general interface to L<P3DataAPI/query> that handles standard
command-line script options for filtering.

=over 4

=item p3

L<P3DataAPI> object for accessing the database.

=item object

User-friendly name of the PATRIC object whose data is desired (e.g. C<genome>, C<genome_feature>).

=item filter

Reference to a list of filter clauses for the query.

=item cols

Reference to a list of the names of the fields to return from the object, or C<undef> if a count is desired.

=item fieldName (optional)

The name of the field in the specified object that is to be used as the key field. If an all-objects query is desired, then
this parameter should be omitted.

=item couplets (optional)

A reference to a list of 2-tuples, each tuple consisting of a key value followed by a reference to a list of the values
from the input row containing that key value.

=item RETURN

Returns a reference to a list of tuples containing the data returned by PATRIC, each output row appended to the appropriate input
row from the couplets.

=back

=cut

sub get_data {
    my ($p3, $object, $filter, $cols, $fieldName, $couplets) = @_;
    # Ths will be the return list.
    my @retVal;
    # Convert the object name.
    my $realName = OBJECTS->{$object};
    # Now we need to form the query modifiers. We start with the column selector. If we're counting, we use the ID column.
    my @selected;
    if (! $cols) {
        @selected = IDCOL->{$object};
    } else {
        my $computed = _select_list($object, $cols);
        @selected = @$computed;
    }
    my @mods = (['select', @selected], @$filter);
    # Finally, we loop through the couplets, making calls. If there are no couplets, we make one call with
    # no additional filtering.
    if (! $fieldName) {
        my @entries = $p3->query($realName, @mods);
        _process_entries($object, \@retVal, \@entries, [], $cols);
    } else {
        # Here we need to loop through the couplets one at a time.
        for my $couplet (@$couplets) {
            my ($key, $row) = @$couplet;
            # Create the final filter.
            my $keyField = ['eq', $fieldName, clean_value($key)];
            # Make the query.
            my @entries = $p3->query($realName, $keyField, @mods);
            # Process the results.
            _process_entries($object, \@retVal, \@entries, $row, $cols);
        }
    }
    # Return the result rows.
    return \@retVal;
}

=head3 get_data_batch

    my $resultList = P3Utils::get_data_batch($p3, $object, \@filter, \@cols, \@couplets, $keyField);

Return all of the indicated fields for the indicated entity (object) with the specified constraints.
This version differs from L</get_data> in that the couplet keys are matched to a true key field (the
matches are exact).

=over 4

=item p3

L<P3DataAPI> object for accessing the database.

=item object

User-friendly name of the PATRIC object whose data is desired (e.g. C<genome>, C<feature>).

=item filter

Reference to a list of filter clauses for the query.

=item cols

Reference to a list of the names of the fields to return from the object, or C<undef> if a count is desired.

=item couplets

A reference to a list of 2-tuples, each tuple consisting of a key value followed by a reference to a list of the values
from the input row containing that key value.

=item keyfield (optional)

The key field to use. If omitted, the object's ID field is used.

=item RETURN

Returns a reference to a list of tuples containing the data returned by PATRIC, each output row appended to the appropriate input
row from the couplets.

=back

=cut

sub get_data_batch {
    my ($p3, $object, $filter, $cols, $couplets, $keyField) = @_;
    # Ths will be the return list.
    my @retVal;
    # Get the real object name and the ID column.
    my $realName = OBJECTS->{$object};
    $keyField //= IDCOL->{$object};
    # Now we need to form the query modifiers. We start with the column selector. We need to insure the key
    # field is included.
    my @keyList;
    if (! scalar(grep { $_ eq $keyField } @$cols)) {
        @keyList = ($keyField);
    }
    my $computed = _select_list($object, $cols);
    my @mods = (['select', @keyList, @$computed], @$filter);
    # Now get the list of key values. These are not cleaned, because we are doing exact matches.
    my @keys = grep { $_ ne '' } map { $_->[0] } @$couplets;
    # Only proceed if we have at least one key.
    if (scalar @keys) {
        # Create a filter for the keys.
        my $keyClause = [in => $keyField, '(' . join(',', @keys) . ')'];
        # Next we run the query and create a hash mapping keys to return sets.
        my @results = $p3->query($realName, $keyClause, @mods);
        my %entries;
        for my $result (@results) {
            my $keyValue = $result->{$keyField};
            push @{$entries{$keyValue}}, $result;
        }
        # Empty the results array to save memory.
        undef @results;
        # Now loop through the couplets, producing output.
        for my $couplet (@$couplets) {
            my ($key, $row) = @$couplet;
            my $entryList = $entries{$key};
            if ($entryList) {
                _process_entries($object, \@retVal, $entryList, $row, $cols);
            }
        }
    }
    # Return the result rows.
    return \@retVal;
}

=head3 get_data_keyed

    my $resultList = P3Utils::get_data_keyed($p3, $object, \@filter, \@cols, \@keys, $keyField);

Return all of the indicated fields for the indicated entity (object) with the specified constraints.
The query is by key, and the keys are split into batches to prevent PATRIC from overloading.

=over 4

=item p3

L<P3DataAPI> object for accessing the database.

=item object

User-friendly name of the PATRIC object whose data is desired (e.g. C<genome>, C<feature>).

=item filter

Reference to a list of filter clauses for the query.

=item cols

Reference to a list of the names of the fields to return from the object, or C<undef> if a count is desired.

=item keys

A reference to a list of key values.

=item keyfield (optional)

The key field to use. If omitted, the object's ID field is used.

=item RETURN

Returns a reference to a list of tuples containing the data returned by PATRIC.

=back

=cut

sub get_data_keyed {
    my ($p3, $object, $filter, $cols, $keys, $keyField) = @_;
    # Ths will be the return list.
    my @retVal;
    # Get the real object name and the ID column.
    my $realName = OBJECTS->{$object};
    $keyField //= IDCOL->{$object};
    # Now we need to form the query modifiers. We start with the column selector. We need to insure the key
    # field is included.
    my @keyList;
    if (! scalar(grep { $_ eq $keyField } @$cols)) {
        @keyList = ($keyField);
    }
    my $computed = _select_list($object, $cols);
    my @mods = (['select', @keyList, @$computed], @$filter);
    # Create a filter for the keys.
    # Loop through the keys, a group at a time.
    my $n = @$keys;
    for (my $i = 0; $i < @$keys; $i += 200) {
        # Split out the keys in this batch.
        my $j = $i + 199;
        if ($j >= $n) { $j = $n - 1 };
        my @keys = @{$keys}[$i .. $j];
        my $keyClause = [in => $keyField, '(' . join(',', @keys) . ')'];
        # Next we run the query and push the output into the return list.
        my @results = $p3->query($realName, $keyClause, @mods);
        _process_entries($object, \@retVal, \@results, [], $cols);
    }
    # Return the result rows.
    return \@retVal;
}

=head3 script_opts

    my $opt = P3Utils::script_opts($parmComment, @options);

Process the command-line options for a P3 script. This method automatically handles the C<--help> option.

=over 4

=item parmComment

A string indicating the command's signature for the positional parameters. Used for the help display.

=item options

A list of options such as are expected by L<Getopt::Long::Descriptive>.

=item RETURN

Returns the options object. Every command-line option's value may be retrieved using a method
on this object.

=back

=cut

sub script_opts {
    # Get the parameters.
    my ($parmComment, @options) = @_;
    # Insure we can talk to PATRIC from inside Argonne.
    $ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;
    # Parse the command line.
    my ($retVal, $usage) = describe_options('%c %o ' . $parmComment, @options,
           [ "help|h", "display usage information", { shortcircuit => 1}]);
    # The above method dies if the options are invalid. We check here for the HELP option.
    if ($retVal->help) {
        print $usage->text;
        exit;
    }
    return $retVal;
}

=head3 print_cols

    P3Utils::print_cols(\@cols, %options);

Print a tab-delimited output row.

=over 4

=item cols

Reference to a list of the values to appear in the output row.

=item options

A hash of options, including zero or more of the following.

=over 8

=item oh

Open file handle for the output stream. The default is \*STDOUT.

=item opt

A L<Getopt::Long::Descriptive::Opts> object containing the delimiter option, for computing the delimiter in multi-valued fields.

=item delim

The delimiter to use in multi-valued fields (overrides C<opt>). The default, if neither this nor C<opt> is specified, is a comma (C<,>).

=back

=back

=cut

sub print_cols {
    my ($cols, %options) = @_;
    # Compute the options.
    my $oh = $options{oh} || \*STDOUT;
    my $opt = $options{opt};
    my $delim = $options{delim};
    if (! defined $delim) {
        if (defined $opt && $opt->delim) {
            $delim = P3Utils::delim($opt);
        } else {
            $delim = ',';
        }
    }
    # Loop through the columns, formatting.
    my @r;
    for my $r (@$cols) {
        if (! defined $r) {
            push(@r, '')
        } elsif (ref($r) eq "ARRAY") {
            my $a = join($delim, @{$r});
            push(@r, $a);
        } else {
            push(@r, $r);
        }
    }
    # Print the columns.
    print $oh join("\t", @r) . "\n";
}


=head3 ih

    my $ih = P3Utils::ih($opt);

Get the input file handle from the options. If no input file is specified in the options,
opens the standard input.

=over 4

=item opt

L<Getopt::Long::Descriptive::Opts> object for the current command-line options.

=item RETURN

Returns an open file handle for the script input.

=back

=cut

sub ih {
    # Get the parameters.
    my ($opt) = @_;
    # Declare the return variable.
    my $retVal;
    # Get the input file name.
    my $fileName = $opt->input;
    # Check for a value.
    if (! $fileName) {
        # Here we have the standard input.
        $retVal = \*STDIN;
    } else {
        # Here we have a real file name.
        open($retVal, "<$fileName") ||
            die "Could not open input file $fileName: $!";
    }
    # Return the open handle.
    return $retVal;
}


=head3 ih_options

    my @opt_specs = P3Utils::ih_options();

These are the command-line options for specifying a standard input file.

=over 4

=item input

Name of the main input file. If omitted and an input file is required, the standard
input is used.

=back

This method returns the specifications for these command-line options in a form
that can be used in the L<ScriptUtils/Opts> method.

=cut

sub ih_options {
    return (
            ["input|i=s", "name of the input file (if not the standard input)"]
    );
}

=head3 match

    my $flag = P3Utils::match($pattern, $key);

Test a match pattern against a key value and return C<1> if there is a match and C<0> otherwise.
If the key is numeric, a numeric equality match is performed. If the key is non-numeric, then
we have a match if any subsequence of the words in the key is equal to the pattern (case-insensitive).
The goal here is to more or less replicate the SOLR B<eq> operator.

=over 4

=item pattern

The pattern to be matched.

=item key

The value against which to match the pattern.

=item RETURN

Returns C<1> if there is a match, else C<0>.

=back

=cut

sub match {
    my ($pattern, $key) = @_;
    # This will be the return value.
    my $retVal = 0;
    # Determine the type of match.
    if ($pattern =~ /^\-?\d+(?:\.\d+)?$/) {
        # Here we have a numeric match.
        if ($pattern == $key) {
            $retVal = 1;
        }
    } else {
        # Here we have a substring match.
        my @patternI = split ' ', lc $pattern;
        my @keyI = split ' ', lc $key;
        for (my $i = 0; ! $retVal && $i < scalar @keyI; $i++) {
            if ($patternI[0] eq $keyI[$i]) {
                my $possible = 1;
                for (my $j = 1; $possible && $j < scalar @patternI; $j++) {
                    if ($patternI[$j] ne $keyI[$i+$j]) {
                        $possible = 0;
                    }
                }
                $retVal = $possible;
            }
        }
    }
    # Return the determination indicator.
    return $retVal;
}

=head3 find_headers

    my (\@headers, \@cols) = P3Utils::find_headers($ih, $fileType => @fields);

Search the headers of the specified input file for the named fields and return the list of headers plus a list of
the column indices for the named fields.

=over 4

=item ih

Open input file handle.

=item fileType

Name to give the input file in error messages.

=item fields

A list of field names for the desired columns.

=item RETURN

Returns a two-element list consisting of (0) a reference to a list of the headers from the input file and
(1) a reference to a list of column indices for the desired columns of the input, in order.

=back

=cut

sub find_headers {
    my ($ih, $fileType, @fields) = @_;
    # Read the column headers from the file.
    my $line = <$ih>;
    my @headers = get_fields($line);
    # Get a hash of the field names.
    my %fieldH = map { $_ => undef } @fields;
    # Loop through the headers, saving indices.
    for (my $i = 0; $i < @headers; $i++) {
        my $header = $headers[$i];
        if (exists $fieldH{$header}) {
            $fieldH{$header} = $i;
        }
    }
    # Now one more time, looking for abbreviated header names.
    for (my $i = 0; $i < @headers; $i++) {
        my @headers = split /\./, $headers[$i];
        my $header = pop @headers;
        if (exists $fieldH{$header} && ! defined $fieldH{$header}) {
            $fieldH{$header} = $i;
        }
    }
    # Accumulate the headers that were not found. We also handle numeric column indices in here.
    my @bad;
    for my $field (keys %fieldH) {
        if (! defined $fieldH{$field}) {
            # Is this a number?
            if ($field =~ /^\d+$/) {
                # Yes, convert it to an index.
                $fieldH{$field} = $field - 1;
            } else {
                # No, we have a bad header.
                push @bad, $field;
            }
        }
    }
    # If any headers were not found, it is an error.
    if (scalar(@bad) == 1) {
        die "Could not find required column \"$bad[0]\" in $fileType file.";
    } elsif (scalar(@bad) > 1) {
        die "Could not find required columns in $fileType file: " . join(", ", @bad);
    }
    # If we got this far, we are ok, so return the results.
    my @cols = map { $fieldH{$_} } @fields;
    return (\@headers, \@cols);
}

=head3 get_cols

    my @values = P3Utils::get_cols($ih, $cols);

This method returns all the values in the specified columns of the next line of the input file, in order. It is meant to be used
as a companion to L</find_headers>. A list reference can be used in place of an open file handle, in which case the columns will
be used to index into the list.

=over 4

=item ih

Open input file handle, or alternatively a list reference.

=item cols

Reference to a list of column indices.

=item RETURN

Returns a list containing the fields in the specified columns, in order.

=back

=cut

sub get_cols {
    my ($ih, $cols) = @_;
    # Get the list of field values according to the input type.
    my @fields;
    if (ref $ih eq 'ARRAY') {
        @fields = @$ih;
    } else {
        # Read the input line.
        my $line = <$ih>;
        # Get the columns.
        @fields = get_fields($line);
    }
    # Extract the ones we want.
    my @retVal = map { $fields[$_] } @$cols;
    # Return the resulting values.
    return @retVal;
}

=head3 get_fields

    my @fields = P3Utils::get_fields($line);

Split a tab-delimited line into fields.

=over 4

=item line

Input line to split.

=item RETURN

Returns a list of the fields in the line.

=back

=cut

sub get_fields {
    my ($line) = @_;
    # Split the line.
    my @retVal = split /\t/, $line;
    # Remove the EOL.
    if (@retVal) {
        $retVal[$#retVal] =~ s/[\r\n]+$//;
    }
    # Return the fields.
    return @retVal;
}

=head3 list_object_fields

    my $fieldList = P3Utils::list_object_fields($object);

Return the list of field names for an object. The database schema is queried directly.

=over 4

=item object

The name of the object whose field names are desired.

=item RETURN

Returns a reference to a list of the field names.

=back

=cut

sub list_object_fields {
    my ($object) = @_;
    my @retVal;
    # Get the real name of the object.
    my $realName = OBJECTS->{$object};
    # Ask for the JSON schema string.
    my $ua = LWP::UserAgent->new();
    my $url = "https://www.patricbrc.org/api/$realName/schema?http_content-type=application/solrquery+x-www-form-urlencoded&http_accept=application/solr+json";
    my $request = HTTP::Request->new(GET => $url);
    my $response = $ua->request($request);
    if ($response->code ne 200) {
        die "Error response from PATRIC: " . $response->message;
    } else {
        my $json = $response->content;
        my $schema = SeedUtils::read_encoded_object(\$json);
        for my $field (@{$schema->{schema}{fields}}) {
            my $string = $field->{name};
            if ($field->{multiValued}) {
                $string .= ' (multi)';
            }
            push @retVal, $string;
        }
        # Get the derived fields.
        my $derivedH = DERIVED->{$object};
        push @retVal, map { "$_ (derived)" } keys %$derivedH;
    }
    # Return the list.
    return [sort @retVal];
}

=head2 Internal Methods

=head3 _process_entries

    P3Utils::_process_entries($object, \@retList, \@entries, \@row, \@cols);

Process the specified results from a PATRIC query and store them in the output list.

=over 4

=item object

Name of the object queried.

=item retList

Reference to a list into which the output rows should be pushed.

=item entries

Reference to a list of query results from PATRIC.

=item row

Reference to a list of values to be prefixed to every output row.

=item cols

Reference to a list of the names of the columns to be put in the output row, or C<undef> if the user wants a count.

=back

=cut

sub _process_entries {
    my ($object, $retList, $entries, $row, $cols) = @_;
    # Are we counting?
    if (! $cols) {
        # Yes. Pop on the count.
        push @$retList, [@$row, scalar(@$entries)];
    } else {
        # No. Generate the data. First we need the derived-field hash.
        my $derivedH = DERIVED->{$object};
        # Loop through the entries.
        for my $entry (@$entries) {
            # Reject the record unless it has real data.
            my $reject = 1;
            # The output columns will be put in here.
            my @outCols;
            # Loop through the columns to create.
            for my $col (@$cols) {
                # Get the rule for this column.
                my $algorithm = $derivedH->{$col} // ['altName', $col];
                my ($function, @fields) = @$algorithm;
                my @values = map { $entry->{$_} } @fields;
                # Verify the values.
                for (my $i = 0; $i < @values; $i++) {
                    if (! defined $values[$i]) {
                        $values[$i] = '';
                    } else {
                        $reject = 0;
                    }
                }
                # Now we compute the output value.
                my $outCol = _apply($function, @values);
                push @outCols, $outCol;
            }
            # Output the record if it is NOT rejected.
            if (! $reject) {
                push @$retList, [@$row, @outCols];
            }
        }
    }
}

=head3 _apply

    my $result = _apply($function, @values);

Apply a computational function to values to produce a computed field value.

=over 4

=item function

Name of the function.

=over 8

=item altName

Pass the input value back unmodified.

=item concatSemi

Concatenate the sub-values using a semi-colon/space separator.

=item md5

Compute an MD5 for a DNA or protein sequence.

=back

=item values

List of the input values.

=item RETURN

Returns the computed result.

=back

=cut

sub _apply {
    my ($function, @values) = @_;
    my $retVal;
    if ($function eq 'altName') {
        $retVal = $values[0];
    } elsif ($function eq 'concatSemi') {
        $retVal = join('; ', @{$values[0]});
    } elsif ($function eq 'md5') {
        $retVal = Digest::MD5::md5_hex(uc $values[0]);
    }
    return $retVal;
}

=head3 _select_list

    my $fieldList = _select_list($object, $cols);

Compute the list of fields required to retrieve the specified columns. This includes the specified normal fields plus any derived fields.

=over 4

=item object

Name of the object being retrieved.

=item cols

Reference to a list of field names.

=item RETURN

Returns a reference to a list of field names to retrieve.

=back

=cut

sub _select_list {
    my ($object, $cols) = @_;
    # The field names will be accumulated in here.
    my %retVal;
    # Get the derived-field hash.
    my $derivedH = DERIVED->{$object};
    # Loop through the field names.
    for my $col (@$cols) {
        my $algorithm = $derivedH->{$col} // ['altName', $col];
        my ($function, @parms) = @$algorithm;
        for my $parm (@parms) {
            $retVal{$parm} = 1;
        }
    }
    # Return the fields needed.
    return [sort keys %retVal];
}

1;
