use v5.10.0;
use warnings;
package JMAP::Tester::Role::Result;
# ABSTRACT: the kind of thing that you get back for a request

use Moo::Role;

use JMAP::Tester::Abort ();

=head1 OVERVIEW

This is the role consumed by the class of any object returned by JMAP::Tester's
C<request> method.  Its only guarantee, for now, is an C<is_success> method,
and an C<http_response> method.

=cut

requires 'is_success';

has http_response => (
  is => 'ro',
);

sub assert_successful {
  my ($self) = @_;

  return $self if $self->is_success;

  my $str = $self->can('has_ident') && $self->has_ident
          ? $self->ident
          : "JMAP failure";

  die JMAP::Tester::Abort->new($str);
}

1;
