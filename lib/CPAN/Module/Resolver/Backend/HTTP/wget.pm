use strict;
use warnings;

package CPAN::Module::Resolver::Backend::HTTP::wget;

# ABSTRACT: Adapter for CPAN::Module::Resolver to use C<wget>

=head1 DESCRIPTION

This is merely a backend implementation for L<< C<CPAN::Module::Resolver>|CPAN::Module::Resolver >>,
via implementing the role L<< C<CPAN::Module::Resolver::Role::HTTPBackend>|CPAN::Module::Resolver::Role::HTTPBackend >>.

It acts to provide a unified interface for requesting data, and uses the C<wget> commandline utility to provide this feature.

See the documentation for L<< C<CPAN::Module::Resolver::Role::HTTPBackend>|CPAN::Module::Resolver::Role::HTTPBackend >> for direct usage details.

=cut

=head1 CREDITS

Logic stolen from L<< C<cpanm>|App::cpanminus >>, by L<< Tatsuhiko Miyagawa|https://metacpan.org/author/MIYAGAWA >>

=cut

use Moo;

with 'CPAN::Module::Resolver::Role::HTTPBackend';

with 'CPAN::Module::Resolver::Role::ShellBackend';

has wget_path         => ( is => lazy => );
has verbose           => ( is => lazy => );
has wget_get_flags    => ( is => lazy => );
has wget_mirror_flags => ( is => lazy => );

sub usable                { return defined $_[0]->_which('wget') }
sub _build_wget_path      { return $_[0]->_which('wget') }
sub _build_verbose        { 0 }
sub _build_wget_get_flags { return [ ( $_[0]->verbose ? () : '-q' ) ] }

sub _build_wget_mirror_flags {
  return [ '--retry-connrefused', ( $_[0]->verbose ? () : '-q' ) ];
}

sub _wget {
  my ( $self, @wget_args ) = @_;
  $self->_safeexec( my $fh, $self->wget_path, @wget_args )
    or die "wget @wget_args : $!";
  local $/;
  return <$fh>;

}

sub get {
  my ( $self, $uri ) = @_;
  return $self->_file_get($uri) if $uri =~ s!^file:/+!/!;
  return $self->_wget( $uri, @{ $self->wget_get_flags }, '-O', '-' );
}

sub mirror {
  my ( $self, $uri, $path ) = @_;
  return $self->_file_mirror( $uri, $path ) if $uri =~ s!^file:/+!/!;
  return $self->_wget( $uri, @{ $self->wget_mirror_flags }, '-O', $path );
}

1;
