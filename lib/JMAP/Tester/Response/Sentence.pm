use v5.10.0;
package JMAP::Tester::Response::Sentence;
# ABSTRACT: a single triple within a JMAP response

use Moo;

=head1 OVERVIEW

These objects represent sentences in the JMAP response.  That is, if your
response is:

  [
    [ "messages", { ... }, "a" ],      # 1
    [ "smellUpdates", { ... }, "b" ],  # 2
    [ "smells",       { ... }, "b" ],  # 3
  ]

...then #1, #2, and #3 are each a single sentence.

The first item in the triple is accessed with the C<name> method.  The second
is accessed with the C<arguments> method.  The third, with the C<client_id>
method.

=cut

sub BUILDARGS {
  my ($self, $args) = @_;
  if (ref $args && ref $args eq 'ARRAY') {
    return {
      name => $args->[0],
      arguments => $args->[1],
      client_id => $args->[2],
    };
  }
  return $self->SUPER::BUILDARGS($args);
}

has name      => (is => 'ro', required => 1);
has arguments => (is => 'ro', required => 1);
has client_id => (is => 'ro', required => 1);

=method as_struct

This returns the underlying JSON data of the sentence, which may include
objects used to convey type information for booleans, strings, and numbers.

It returns a three-element arrayref.

=cut

sub as_struct { [ $_[0]->name, $_[0]->arguments, $_[0]->client_id ] }

=method as_pair

This method returns the same thing as C<as_struct>, but without the
C<client_id>.  That means it returns a two-element arrayref.

=cut

sub as_pair { [ $_[0]->name, $_[0]->arguments ] }

=method as_set

This method returns a L<JMAP::Tester::Response::Sentence::Set> object for the
current sentence.  That's a specialized Sentence for C<setFoos>-style JMAP
method responses.

=cut

sub as_set {
  require JMAP::Tester::Response::Sentence::Set;
  return JMAP::Tester::Response::Sentence::Set->new({
    name      => $_[0]->name,
    arguments => $_[0]->arguments,
    client_id => $_[0]->client_id,
  });
}

1;
