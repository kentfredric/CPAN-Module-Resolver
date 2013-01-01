
use strict;
use warnings;

package CPAN::Module::Resolver::Backend::search_cpan_org;

# ABSTRACT: Resolve a module via searching search.cpan.org

=head1 DESCRIPTION

This is merely a backend implementation for L<< C<CPAN::Module::Resolver>|CPAN::Module::Resolver >>,
via implementing the role L<< C<CPAN::Module::Resolver::Role::Resolver>|CPAN::Module::Resolver::Role::Resolver >>.

It queries L<< B<search.cpan.org>|http://search.cpan.org/ >> to find the requested module.

See the documentation for L<< C<CPAN::Module::Resolver::Role::Resolver>|CPAN::Module::Resolver::Role::Resolver >> for direct usage details.

=cut

=head1 CREDITS

Logic stolen from L<< C<cpanm>|App::cpanminus >>, by L<< Tatsuhiko Miyagawa|https://metacpan.org/author/MIYAGAWA >>

=cut

use Moo;
use CPAN::Module::Resolver::Result;

with 'CPAN::Module::Resolver::Role::Resolver';

has base_uri => ( is => lazy => );

sub _build_base_uri { return 'http://search.cpan.org/perldoc?%s' }
sub _uri_for { my $self = shift; return sprintf $self->base_uri, @_ }
sub _module_html { my $self = shift; return $self->get( $self->_uri_for(@_) ) }
sub usable { 1 }

sub resolve {
  my ( $self, $modname ) = @_;

  my $html = $self->_module_html($modname);
  return unless $html;
  if ( $html =~ m!<a href="/CPAN/authors/id/(.*?[.](?:tar[.]gz|tgz|tar[.]bz2|zip))">! ) {
	return CPAN::Module::Resolver::Result->new( 
		module => $modname, 
		dist => $1
	);
  }
  return;
}

1;
