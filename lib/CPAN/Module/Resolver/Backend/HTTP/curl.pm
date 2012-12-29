use strict;
use warnings;

package CPAN::Module::Resolver::Backend::HTTP::curl;
# ABSTRACT: Adapter for CPAN::Module::Resolver to use C<curl>

=head1 DESCRIPTION

This is merely a backend implementation for L<< C<CPAN::Module::Resolver>|CPAN::Module::Resolver >>, 
via implementing the role L<< C<CPAN::Module::Resolver::Role::HTTPBackend>|CPAN::Module::Resolver::Role::HTTPBackend >>.

It acts to provide a unified interface for requesting data, and uses the C<curl> commandline utility to provide this feature.

See the documentation for L<< C<CPAN::Module::Resolver::Role::HTTPBackend>|CPAN::Module::Resolver::Role::HTTPBackend >> for direct usage details.

=cut

=head1 CREDITS

Logic stolen from L<< C<cpanm>|App::cpanminus >>, by L<< Tatsuhiko Miyagawa|https://metacpan.org/author/MIYAGAWA >>

=cut

use Moo;

with 'CPAN::Module::Resolver::Role::HTTPBackend';
with 'CPAN::Module::Resolver::Role::ShellBackend';

has curl_path         => ( is => lazy => );
has verbose           => ( is => lazy => );
has curl_get_flags    => ( is => lazy => );
has curl_mirror_flags => ( is => lazy => );

sub usable                   { return defined $_[0]->_which('curl') }
sub _build_curl_path         { return $_[0]->_which('curl') }
sub _build_verbose           { 0 }
sub _build_curl_get_flags    { return [ '-L', ( $_[0]->verbose ? () : '-s' ) ] }
sub _build_curl_mirror_flags { return [ '-L', ( $_[0]->verbose ? () : '-s' ) , '-#', ], }

sub _curl {
	my ($self, @curlargs ) = @_;
 	$self->_safeexec( $fh, $self->curl_path, @curlags )
		 or die "curl @curlargs: $!";
	local $/;
	return <$fh>;
}

sub get {
    my ( $self, $uri ) = @_;
    return $self->_file_get($uri) if $uri =~ s!^file:/+!/!;
	return $self->_curl( $uri, @{ $self->curl_flags }, )
}
sub mirror {
    my ( $self, $uri, $path ) = @_;
    return $self->_file_mirror($uri) if $uri =~ s!^file:/+!/!;
	return $self->_curl( $uri, @{ $self->curl_flags }, '-o', $path );
}


1;
