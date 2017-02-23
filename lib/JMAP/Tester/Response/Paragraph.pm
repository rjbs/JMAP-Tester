use v5.10.0;
package JMAP::Tester::Response::Paragraph;
# ABSTRACT: a group of sentences in a JMAP response

use Moo;

use JMAP::Tester::Abort 'abort';

use namespace::clean;

=head1 OVERVIEW

These objects represent paragraphs in the JMAP response.  That is, if your
response is:

  [
    [ "messages", { ... }, "a" ],      # 1
    [ "smellUpdates", { ... }, "b" ],  # 2
    [ "smells",       { ... }, "b" ],  # 3
  ]

...then #1 forms one paragraph and #2 and #3 together form another.  It goes by
matching client ids.

=cut

sub client_id {
  my ($self) = @_;
  $self->_sentences->[0]->client_id;
}

sub BUILD {
  abort("tried to build 0-sentence paragraph")
    unless @{ $_[0]->_sentences };

  my $client_id = $_[0]->_sentences->[0]->client_id;
  abort("tried to build paragraph with non-uniform client_ids")
    if grep {; $_->client_id ne $client_id } @{ $_[0]->_sentences };
}

has sentences => (is => 'bare', reader => '_sentences', required => 1);

has _json_typist => (
  is => 'ro',
  handles => {
    _strip_json_types => 'strip_types',
  },
);

=method sentences

The C<sentences> method returns a list of
L<Sentence|JMAP::Tester::Response::Sentence> objects, one for each sentence
in the paragraph.

=cut

sub sentences { @{ $_[0]->_sentences } }

=method sentence

  my $sentence = $para->sentence($n);

This method returns the I<n>th sentence of the paragraph.

=cut

sub sentence {
  my ($self, $n) = @_;
  abort("there is no sentence for index $n")
    unless $self->_sentences->[$n];
}

=method single

  my $sentence = $para->single;
  my $sentence = $para->single($name);

This method throws an exception if there is more than one sentence in the
paragraph.  If a C<$name> argument is given and the paragraph's single
sentence doesn't have that name, an exception is raised.

Otherwise, this method returns the sentence.

=cut

sub single {
  my ($self, $name) = @_;

  my @sentences = $self->sentences;

  Carp::confess("more than one sentence in set, but ->single called")
    if @sentences > 1;

  Carp::confess("single sentence not of expected name <$name>")
    if defined $name && $name ne $sentences[0]->name;

  return $sentences[0];
}

=method sentence_named

  my $sentence = $paragraph->sentence_named($name);

This method returns the sentence with the given name.  If no such sentence
exists, or if two sentences with the name exist, the tester will abort.

=cut

sub sentence_named {
  my ($self, $name) = @_;

  Carp::confess("no name given") unless defined $name;

  my @sentences = grep {; $_->name eq $name } $self->sentences;

  unless (@sentences) {
    abort(qq{no sentence found with name "$name"});
  }

  if (@sentences > 1) {
    abort(qq{found more than one sentence with name "$name"});
  }

  return $sentences[0];
}

=method as_struct

=method as_stripped_struct

C<as_struct> returns an arrayref containing the result of calling C<as_struct>
on each sentence in the paragraph. C<as_stripped_struct> removes JSON types.

=cut

sub as_struct {
  [ map {; $_->as_struct } $_[0]->sentences ]
}

sub as_stripped_struct {
  $_[0]->_strip_json_types($_[0]->as_struct);
}

=method as_pairs

C<as_pairs> returns an arrayref containing the result of calling C<as_pair>
on each sentence in the paragraph. C<as_stripped_pairs> removes JSON types.

=cut

sub as_pairs {
  [ map {; $_->as_pair } $_[0]->sentences ]
}

sub as_stripped_pairs {
  $_[0]->_strip_json_types($_[0]->as_pairs);
}

1;
