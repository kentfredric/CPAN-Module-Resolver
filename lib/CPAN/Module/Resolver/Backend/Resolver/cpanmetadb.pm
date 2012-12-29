use strict;
use warnings;

package CPAN::Module::Resolver::Backend::Resolver::cpanmetadb;

# ABSTRACT: Resolve a module via the cpanmetadb

=head1 DESCRIPTION

This is merely a backend implementation for L<< C<CPAN::Module::Resolver>|CPAN::Module::Resolver >>, 
via implementing the role L<< C<CPAN::Module::Resolver::Role::Resolver>|CPAN::Module::Resolver::Role::Resolver >>.

It queries the "cpanmetadb" ( L<< B<cpanmetadb.plackperl.org>|http://cpanmetadb.plackperl.org/ >> ).

See the documentation for L<< C<CPAN::Module::Resolver::Role::Resolver>|CPAN::Module::Resolver::Role::Resolver >> for direct usage details.



=cut

=head1 CREDITS

Logic stolen from L<< C<cpanm>|App::cpanminus >>, by L<< Tatsuhiko Miyagawa|https://metacpan.org/author/MIYAGAWA >>

=cut

use Moo;
use Module::Runtime;
use CPAN::Module::Resolver::Result;

with 'CPAN::Module::Resolver::Role::Resolver';

has base_uri => ( is => lazy => );

sub usable {
  return eval { Module::Runtime::require_module('Parse::CPAN::Meta'); };
}

sub _parse_meta_string {
  my ( $self, $string ) = @_;
  return eval { ( Parse::CPAN::Meta::Load($string) )[0] } || undef;
}
sub _build_base_uri { 'http://cpanmetadb.plackperl.org/v1.0/package/%s' }
sub _uri_for_module { my $self = shift; return sprintf $self->base_uri, @_; }
sub _module_yaml { my $self = shift; return $self->get( $self->_uri_for_module(@_) ) }
sub _module_data { my $self = shift; return $self->_parse_meta_string( $self->_module_yaml(@_) ) }

sub resolve {
  my ( $self, $module ) = @_;
  my $meta = $self->_module_data($module);
  return unless ( $meta && $meta->{distfile} );
  return CPAN::Module::Resolver::Result->new(
    module => $module,
    dist   => $meta->{distfile},
    ( $meta->{version} && $meta->{version} ne 'undef' ) ? ( version => $meta->{version} ) : ()
  );
}

1;
