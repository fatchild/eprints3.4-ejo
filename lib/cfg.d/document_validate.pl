######################################################################
#
# validate_document( $document, $repository, $for_archive ) 
#
######################################################################
# $document 
# - Document object
# $repository 
# - Repository object (the current repository)
# $for_archive
# - boolean (see comments at the start of the validation section)
#
# returns: @problems
# - ARRAY of DOM objects (may be null)
#
######################################################################
# Validate a document. validate_document_meta will be called auto-
# matically, so you don't need to duplicate any checks.
#
######################################################################


$c->{validate_document} = sub
{
	my( $document, $repository, $for_archive ) = @_;

	my @problems = ();

	my $xml = $repository->xml();

	# CHECKS IN HERE

	# "other" documents must have a description set
	if( $document->value( "format" ) eq "other" &&
	   !EPrints::Utils::is_set( $document->value( "formatdesc" ) ) )
	{
		my $fieldname = $xml->create_element( "span", class=>"ep_problem_field:documents" );
		push @problems, $repository->html_phrase( 
					"validate:need_description" ,
					type=>$document->render_citation("brief"),
					fieldname=>$fieldname );
	}

	# security can't be "public" if date embargo set
	if( !$repository->config( "retain_embargo_dates" ) && 
	    $document->value( "security" ) eq "public" &&
		EPrints::Utils::is_set( $document->value( "date_embargo" ) )
		)
	{
		my $fieldname = $xml->create_element( "span", class=>"ep_problem_field:documents" );
		push @problems, $repository->html_phrase( 
					"validate:embargo_check_security" ,
					fieldname=>$fieldname );
	}

	# embargo expiry date must be a full year, month and day and must be in the future
	if( EPrints::Utils::is_set( $document->value( "date_embargo" ) ) )
	{
		my $value = $document->value( "date_embargo" );
		my ($year, $month, $day) = split( '-', $value );
		my ($thisyear, $thismonth, $thisday) = EPrints::Time::get_date_array();

		if ( !EPrints::Utils::is_set( $month ) || !EPrints::Utils::is_set( $day ) )
		{
			my $fieldname = $xml->create_element( "span", class=>"ep_problem_field:documents" );
                        push @problems, $repository->html_phrase( "validate:embargo_incomplete_date", fieldname=>$fieldname );
		}
		elsif ( !$repository->config( "retain_embargo_dates" ) )
		{
			if( $year < $thisyear || ( $year == $thisyear && $month < $thismonth ) ||
				( $year == $thisyear && $month == $thismonth && $day <= $thisday ) )
			{
				my $fieldname = $xml->create_element( "span", class=>"ep_problem_field:documents" );
				push @problems,
					$repository->html_phrase( "validate:embargo_invalid_date",
					fieldname=>$fieldname );
			}
		}
		elsif ( $document->value( "security" ) eq "public" && ( $year > $thisyear || ( $year == $thisyear && $month > $thismonth ) || 
			( $year == $thisyear && $month == $thismonth && $day > $thisday ) ) )
		{
			my $fieldname = $xml->create_element( "span", class=>"ep_problem_field:documents" );
			push @problems, $repository->html_phrase(
				"validate:embargo_check_security",
				fieldname=>$fieldname );
		}
	}


	return( @problems );
};

=head1 COPYRIGHT

=for COPYRIGHT BEGIN

Copyright 2022 University of Southampton.
EPrints 3.4 is supplied by EPrints Services.

http://www.eprints.org/eprints-3.4/

=for COPYRIGHT END

=for LICENSE BEGIN

This file is part of EPrints 3.4 L<http://www.eprints.org/>.

EPrints 3.4 and this file are released under the terms of the
GNU Lesser General Public License version 3 as published by
the Free Software Foundation unless otherwise stated.

EPrints 3.4 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with EPrints 3.4.
If not, see L<http://www.gnu.org/licenses/>.

=for LICENSE END

