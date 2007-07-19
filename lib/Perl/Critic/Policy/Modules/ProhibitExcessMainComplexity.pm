##############################################################################
#      $URL$
#     $Date$
#   $Author$
# $Revision$
##############################################################################

package Perl::Critic::Policy::Modules::ProhibitExcessMainComplexity;

use strict;
use warnings;

use Perl::Critic::Utils qw{ :severities };
use Perl::Critic::Utils::McCabe qw{ &calculate_mccabe_of_main };

use base 'Perl::Critic::Policy';

#-----------------------------------------------------------------------------

our $VERSION = 1.06;

#-----------------------------------------------------------------------------

my $EXPL = q{Consider refactoring};

#-----------------------------------------------------------------------------

my $DEFAULT_MAX_MCCABE = 20;

sub supported_parameters {
    return qw{ max_mccabe };
}

sub default_severity { return $SEVERITY_MEDIUM                }
sub default_themes   { return qw(core complexity maintenance) }
sub applies_to       { return 'PPI::Document'                 }

#-----------------------------------------------------------------------------

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    my (%config) = @_;

    my $max_mccabe = $config{max_mccabe};
    if (
            not $max_mccabe
        or  $max_mccabe !~ m/ \A \d+ \z /xms
        or  $max_mccabe < 1
    ) {
        $max_mccabe = $DEFAULT_MAX_MCCABE;
    }

    $self->{_max_mccabe} = $max_mccabe;

    return $self;
}

#-----------------------------------------------------------------------------

sub violates {
    my ( $self, $doc, undef ) = @_;

    my $score = calculate_mccabe_of_main( $doc );

    # Is it too complex?
    return if $score <= $self->{_max_mccabe};

    my $desc = qq{Main code has high complexity score ($score)};
    return $self->violation( $desc, $EXPL, $doc );
}


1;

__END__

#-----------------------------------------------------------------------------

=pod

=for stopwords McCabe

=head1 NAME

Perl::Critic::Policy::Modules::ProhibitExcessMainComplexity

=head1 DESCRIPTION

All else being equal, complicated code is more error-prone and more expensive
to maintain than simpler code.  The first step towards managing complexity is
to establish formal complexity metrics.  One such metric is the McCabe score,
which describes the number of possible paths through a block of code.  This
Policy approximates the McCabe score by summing the number of conditional
statements and operators within a block of code.  Research has shown that a
McCabe score higher than 20 is a sign of high-risk, potentially untestable
code.  See L<http://www.sei.cmu.edu/str/descriptions/cyclomatic_body.html> for
some discussion about the McCabe number and other complexity metrics.

Whereas L<Perl::Critic::Policy::Subroutines::ProhibitExcessComplexity> scores
the complexity of each subroutine, this Policy scores the total complexity of
all the code that is B<outside> of any subroutine declaration.

The usual prescription for reducing complexity is to refactor code into
smaller subroutines.  Mark Dominus book "Higher Order Perl" also describes
callbacks, recursion, memoization, iterators, and other techniques that help
create simple and extensible Perl code.

=head1 CONFIGURATION

The maximum acceptable McCabe score can be set with the C<max_mccabe>
configuration item.  If the sum of all code B<outside> any subroutine has a
McCabe score higher than this number, it will generate a Policy violation.
The default is 20.  An example section for a F<.perlcriticrc>:

  [Modules::ProhibitExcessMainComplexity]
  max_mccabe = 30

=head1 NOTES


  "Everything should be made as simple as possible, but no simpler."

                                                  -- Albert Einstein


Complexity is subjective, but formal complexity metrics are still incredibly
valuable.  Every problem has an inherent level of complexity, so it is not
necessarily optimal to minimize the McCabe number.  So don't get offended if
your code triggers this Policy.  Just consider if there B<might> be a simpler
way to get the job done.

=head1 SEE ALSO

L<Perl::Critic::Policy::Subroutines::ProhibitExcessComplexity>

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2005-2007 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab :