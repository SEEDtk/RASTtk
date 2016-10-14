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

=head1 PATRIC Script Utilities

This module contains shared utilities for PATRIC 3 scripts.

=head2 Constants

These constants define the sort-of ER model for PATRIC.

=head3 OBJECTS

Mapping from user-friendly names to PATRIC names.

=cut

use constant OBJECTS => {   genome => 'genome', feature => 'genome_feature', family => 'protein_family_ref',
                            genome_drug => 'genome_amr' };

=head3 FIELDS

Mapping from user-friendly object names to default fields.

=cut

use constant FIELDS =>  {   genome => ['genome_id', 'genome_name', 'taxon_id', 'genome_status', 'gc_content'],
                            feature => ['patric_id', 'feature_type', 'location', 'product'],
                            family => ['family_id', 'family_type', 'family_product'],
                            genome_drug => ['genome_id', 'antibiotic', 'resistant_phenotype'] };

=head3 IDCOL

Mapping from user-friendly object names to ID column names.

=cut

use constant IDCOL =>   {   genome => 'genome_id', feature => 'patric_id', family => 'family_id',
                            genome_drug => 'id' };

=head2  Methods

=head3 data_options

    my @opts = P3Utils::data_options();

This method returns a list of the L<Getopt::Long::Descriptive> specifications for the common data retrieval
options. These options are as follows.

=over 4

=item attr

Names of the fields to return. Multiple field names may be specified by coding the option multiple times.

=item equal

Equality constraints of the form I<field-name>C<,>I<value>. If the field is numeric, the constraint will be an
exact match. If the field is a string, the constraint will be a substring match. An asterisk in string values
is interpreted as a wild card. Multiple equality constraints may be specified by coding the option multiple
times.

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
            ['equal|eq|e=s@', 'search constraint(s) in the form field_name,value'],
            ['in=s@', 'any-value search constraint(s) in the form field_name,value1,value2,...,valueN'],
            ['required|r=s@', 'field(s) required to have values']);
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

=back

=cut

sub col_options {
    return (['col|c=s', 'column number (1-based) or name', { default => 0 }],
                ['batchSize|b=i', 'input batch size', { default => 100 }]);
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

A L<Getopts::Long::Descriptive::Opt> object containing the batch size specification.

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
            # Remove the EOL.
            $line =~ s/[\r\n]+$//;
            # Split the line into fields.
            my @fields = split /\t/, $line;
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
        # Remove the EOL.
        $line =~ s/[\r\n]+$//;
        # Split the line into fields.
        my @fields = split /\t/, $line;
        # Extract the key column.
        push @retVal, $fields[$colNum];
    }
    # Return the result.
    return \@retVal;
}

=head3 process_headers

    my ($outHeaders, $keyCol) = P3Utils::process_headers($ih, $opt);

Read the header line from a tab-delimited input, format the output headers and compute the index of the key column.

=over 4

=item ih

Open input file handle.

=item opt (optional)

If specified, should be a L<Getopts::Long::Descriptive::Opt> object containing the specifications for the key
column or a string containing the key column name. If this parameter is undefined or omitted, it will be presumed 
there is no key column.

=item RETURN

Returns a two-element list consisting of a reference to a list of the header values and the 0-based index of the key
column. If there is no key column, the second element of the list will be undefined.

=back

=cut

sub process_headers {
    my ($ih, $opt) = @_;
    # Read the header line.
    my $line = <$ih>;
    die "Input file is empty.\n" if (! defined $line);
    # Remove the EOL characters.
    $line =~ s/[\r\n]+$//;
    # Split the line into fields.
    my @outHeaders = split /\t/, $line;
    # This will contain the key column number.
    my $keyCol;
    # Search for the key column.
    if (defined $opt) {
        my $col;
        if (ref $opt) {
            $col = $opt->col;
        } else {
            $col = $opt;
        }
        if ($col =~ /^\-?\d+$/) {
            # Here we have a column number.
            $keyCol = $col - 1;
        } else {
            # Here we have a header name.
            my $n = scalar @outHeaders;
            for ($keyCol = 0; $keyCol < $n && $outHeaders[$keyCol] ne $col; $keyCol++) {};
            die "\"$col\" not found in headers." if ($keyCol >= $n); 
        }
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
        die "\"$col\" not found in headers." if ($retVal >= $n); 
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
    # Get the equality constraints.
    my $eqList = $opt->equal // [];
    for my $eqSpec (@$eqList) {
        # Get the field name and value.
        my ($field, $value);
        if ($eqSpec =~ /(\w+),(.+)/) {
            ($field, $value) = ($1, clean_value($2));
        } else {
            die "Invalid --equal specification $eqSpec.";
        }
        # Apply the constraint.
        push @retVal, ['eq', $field, $value];
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

L<Getopt::Long::Descriptive::Opt> object for the command-line options, including the C<--attr> option.

=item idFlag

If TRUE, then only the ID column will be specified if no attributes are explicitly specified. and if attributes are
explicitly specified, the ID column will be added if it is not present.

=item RETURN

Returns a two-element list consisting of a reference to a list of the names of the
fields to retrieve, and a reference to a list of the proposed headers for the new columns.

=back

=cut

sub select_clause {
    my ($object, $opt, $idFlag) = @_;
    # Validate the object.
    my $realName = OBJECTS->{$object};
    die "Invalid object $object." if (! $realName);
    # Get the attribute option.
    my $attrList = $opt->attr;
    if (! $attrList) {
        if ($idFlag) {
            $attrList = [IDCOL->{$object}];
        } else {
            $attrList = FIELDS->{$object};
        }
    } elsif ($idFlag) {
        my $idCol = IDCOL->{$object};
        if (! scalar(grep { $_ eq $idCol } @$attrList)) {
            unshift @$attrList, $idCol;
        }
    }
    # Form the header list.
    my @headers = map { "$object.$_" } @$attrList;
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

Reference to a list of the names of the fields to return from the object.

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
    # Now we need to form the query modifiers. We start with the column selector.
    my @mods = (['select', @$cols], @$filter);
    # Finally, we loop through the couplets, making calls. If there are no couplets, we make one call with
    # no additional filtering.
    if (! $fieldName) {
        my @entries = $p3->query($realName, @mods);
        _process_entries(\@retVal, \@entries, [], $cols);
    } else {
        # Here we need to loop through the couplets one at a time.
        for my $couplet (@$couplets) {
            my ($key, $row) = @$couplet;
            # Create the final filter.
            my $keyField = ['eq', $fieldName, clean_value($key)];
            # Make the query.
            my @entries = $p3->query($realName, $keyField, @mods);
            # Process the results.
            _process_entries(\@retVal, \@entries, $row, $cols);
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

Reference to a list of the names of the fields to return from the object.

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
    my @mods = (['select', @keyList, @$cols], @$filter);
    # Now get the list of key values. These are not cleaned, because we are doing exact matches.
    my @keys = map { $_->[0] } @$couplets;
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
    # Loop through the couplets, producing output.
    for my $couplet (@$couplets) {
        my ($key, $row) = @$couplet;
        my $entryList = $entries{$key};
        if ($entryList) {
            _process_entries(\@retVal, $entryList, $row, $cols);
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

Reference to a list of the names of the fields to return from the object.

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
    my @mods = (['select', @keyList, @$cols], @$filter);
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
        _process_entries(\@retVal, \@results, [], $cols);
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

    P3Utils::print_cols(\@cols, $oh);

Print a tab-delimited output row.

=over 4

=item cols

Reference to a list of the values to appear in the output row.

=item oh (optional)

Open output file handle. The default is the standard output.

=back

=cut

sub print_cols {
    my ($cols, $oh) = @_;
    $oh //= \*STDOUT;
    print $oh join("\t", @$cols) . "\n";
}


=head3 ih

    my $ih = P3Utils::ih($opt);

Get the input file handle from the options. If no input file is specified in the options,
opens the standard input.

=over 4

=item opt

L<Getopt::Long::Descriptive::Opt> object for the current command-line options. 

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
we have a match if any substring of the key is equal to the pattern (case-insensitive). The goal
here is to more or less replicate the SOLR B<eq> operator.

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
    if ($pattern =~ /^\-?\d+(?:\.\d+)?/) {
        # Here we have a numeric match.
        if ($pattern == $key) {
            $retVal = 1;
        }
    } else {
        # Here we have a substring match.
        my $patternI = lc $pattern;
        my $keyI = lc $key;
        if (index($keyI, $patternI) >= 0) {
            $retVal = 1;
        }
    }
    # Return the determination indicator.
    return $retVal;
}

=head3 match_headers

    my (\@headers, \@cols) = P3Utils::match_headers($ih, $fileType => @fields);

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
    $line =~ s/[\r\n]+$//;
    my @headers = split /\t/, $line;
    # Get a hash of the field names.
    my %fieldH = map { $_ => undef } @fields;
    # Loop through the headers, saving indices.
    for (my $i = 0; $i < @headers; $i++) {
        my $header = $headers[$i];
        if (exists $fieldH{$header}) {
            $fieldH{$header} = $i;
        }
    }
    # Accumulate the headers that were not found.
    my @bad;
    for my $field (keys %fieldH) {
        if (! defined $fieldH{$field}) {
            push @bad, $field;
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

This method returns all the values in the specified columns of the input file, in order. It is meant to be used
as a companion to L</find_headers>.

=over 4

=item ih

Open input file handle.

=item cols

Reference to a list of column indices.

=item RETURN

Returns a list containing the fields in the specified columns, in order.

=back

=cut

sub get_cols {
    my ($ih, $cols) = @_;
    # Read the input line.
    my $line = <$ih>;
    $line =~ s/[\r\n]+$//;
    # Get the columns.
    my @fields = split /\t/, $line;
    # Extract the ones we want.
    my @retVal = map { $fields[$_] } @$cols;
    # Return the resulting values.
    return @retVal;
}

=head2 Internal Methods

=head3 _process_entries

    P3Utils::_process_entries(\@retList, \@entries, \@row, \@cols);

Process the specified results from a PATRIC query and store them in the output list.

=over 4

=item retList

Reference to a list into which the output rows should be pushed.

=item entries

Reference to a list of query results from PATRIC.

=item row

Reference to a list of values to be prefixed to every output row.

=item cols

Reference to a list of the names of the columns to be put in the output row.

=back

=cut

sub _process_entries {
    my ($retList, $entries, $row, $cols) = @_;
    for my $entry (@$entries) {
        my @outCols = map { $entry->{$_} } @$cols;
        # Process the columns. If any are undefined, we change them
        # to empty strings. If all are undefined, we throw away the
        # record.
        my $reject = 1;
        for (my $i = 0; $i < @outCols; $i++) {
            if (! defined $outCols[$i]) {
                $outCols[$i] = '';
            } else {
                $reject = 0;
            }
        }
        # Output the record if it is NOT rejected.
        if (! $reject) {
            push @$retList, [@$row, @outCols];
        }
    }
}

1;
