
use strict;
use warnings;

package CPAN::Module::Resolver::Backend::Resolver::metacpan;

# ABSTRACT: Resolve a module via metacpan

=head1 DESCRIPTION

This is merely a backend implementation for L<< C<CPAN::Module::Resolver>|CPAN::Module::Resolver >>,
via implementing the role L<< C<CPAN::Module::Resolver::Role::Resolver>|CPAN::Module::Resolver::Role::Resolver >>.

It queries the "metacpan api" ( L<< B<api.metacpan.org>|https://github.com/CPAN-API/cpan-api/wiki/Beta-API-docs >> ).

See the documentation for L<< C<CPAN::Module::Resolver::Role::Resolver>|CPAN::Module::Resolver::Role::Resolver >> for direct usage details.

=cut

=head1 CREDITS

Logic stolen from L<< C<cpanm>|App::cpanminus >>, by L<< Tatsuhiko Miyagawa|https://metacpan.org/author/MIYAGAWA >>

=cut

use Moo;
use Module::Runtime;
use CPAN::Module::Resolver::Result;

with 'CPAN::Module::Resolver::Role::Resolver';

has module_base_uri => ( is => lazy => );
has dist_base_uri   => ( is => lazy => );

sub _build_module_base_uri { 'http://api.metacpan.org/module/%s' }
sub _build_dist_base_uri   { 'http://api.metacpan.org/release/%s' }

sub _uri_for_module { my $self = shift; return sprintf $self->module_base_uri, @_ }
sub _uri_for_dist   { my $self = shift; return sprintf $self->dist_base_uri,   @_ }
sub _module_json    { my $self = shift; return $self->get( $self->_uri_for_module(@_) ) }
sub _dist_json      { my $self = shift; return $self->get( $self->_uri_for_dist(@_) ) }
sub _module_data    { my $self = shift; return $self->_safe_decode( $self->_module_json(@_) ) }
sub _dist_data      { my $self = shift; return $self->_safe_decode( $self->_dist_json(@_) ) }

sub _safe_decode {
  my $self = shift;
  return eval { JSON::PP::decode_json(@_) };
}

sub usable {
  return eval { Module::Runtime::require_module('JSON::PP'); };
}

sub resolve {
  my ( $self, $modname ) = @_;

  my $module_meta = $self->_module_data($modname);

  return unless ( $module_meta && $module_meta->{distribution} );

  my $dist_meta = $self->_dist_data( $module_meta->{distribution} );

  return unless $dist_meta && $dist_meta->{download_url};

  ( my $distfile = $dist_meta->{download_url} ) =~ s!.+/authors/id/!!;

  return CPAN::Module::Resolver::Result->new(
    module => $modname,
    dist   => $distfile,
    ( ( $dist_meta->{version} && $dist_meta->{version} ne 'undef' ) ? ( version => $dist_meta->{version} ) : () ),
    ( ( $dist_meta->{stat}->{mtime} > time() - 24 * 60 * 60 ) ? ( mirrors => ['http://cpan.metacpan.org'] ) : () ),
  );
}

1;
