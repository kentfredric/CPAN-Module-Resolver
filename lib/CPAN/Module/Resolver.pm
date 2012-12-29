use strict;
use warnings;

package CPAN::Module::Resolver;

# ABSTRACT: Resolve module names to the dists they are contained in

=head1 DESCRIPTION

There are many ways to resolve what package a module is contained in, and this is a primary feature of any CPAN Client.

This module simply aims to unify all the different ways of doing it via one simple interface:

	use CPAN::Module::Resolver;

	my $resolver = CPAN::Module::Resolver->new();
	my $result   = $resolver->resolve('Moose');

	for my $uri ( $result->uris  ){
		print "$uri\n";
	}

And this does a many things automatically to make life easier:

=over 4

=item * Automatically chooses from all available HTTP Methods, presently consisting of

=over 6

=item * LWP

=item * wget

=item * curl

=item * HTTP::Tiny

=back

=item * Automatically uses available web services to query the results, using one of 

=over 6

=item * cpanmetadb

=item * metacpan api

=item * searching search.cpan.org

=back

=back

And additionally, you can choose which HTTP backend to use, and which query interface to call. 

	my $resolver = CPAN::Module::Resolver->new(
		backend_http_order    => [qw( LWP wget curl fake )],   						# uses the first one that works
		backend_resolve_order => [qw( metacpan cpanmetadb search_cpan_org )],		# uses first successful result.
	);
	

Most the code at present is stolen from bits of the ever popular L<< C<cpanm>|App::cpanminus >>

=cut

use Moo;
use Try::Tiny;

has backend_resolve_order => ( is => lazy => );
has backend_http_order    => ( is => lazy => );
has backend_http          => ( is => lazy => );

sub _get    { my $self = shift; return $self->backend_http->get(@_) }
sub _mirror { my $self = shift; return $self->backend_http->mirror(@_) }

sub _build_backend_resolve_order { return [qw( cpanmetadb search_cpan_org )]; }
sub _build_backend_http_order    { return [qw( LWP wget curl HTTP::Tiny )] }

sub _carp { require Carp; return Carp::carp(@_) }
sub _carpf { my $format = shift; return _carp( sprintf $format, @_ ) }
sub _croak { require Carp; return Carp::croak(@_) }

sub _load_backend {
  my ( $self, $suffix, $backend ) = @_;
  my $backend_group = Module::Runtime::compose_module_name( 'CPAN::Module::Resolver::Backend', $suffix );
  my $modname = Module::Runtime::compose_module_name( $backend_group, $backend );
  return try {
    Module::Runtime::require_module($modname);
    return $modname;
  }
  catch {
    _carpf( "'%s' backend %s failed to load, trying next\n\n%s\n\n", $suffix, $backend, $_ );
    return;
  };
}

sub _usable_backend {
  my ( $self, $suffix, $backend, $cargs ) = @_;
  my $modname = $self->_load_backend( $suffix, $backend );
  return unless $modname;
  my $instance = $modname->new( @{$cargs} );
  if ( not $instance->usable() ) {
    _carpf( "'%s' backend %s unusable, trying next", $suffix, $backend, $modname );
    return;
  }
  return $instance;
}

sub _build_backend_http {
  my ($self) = shift;
  require Module::Runtime;
  for my $backend ( @{ $self->backend_http_order } ) {
    my $instance = $self->_usable_backend( 'HTTP', $backend, [] );
    next unless $instance;
    return $instance;
  }
  _croak("None of the specified backends were loadable/useable");
}

sub resolve {
  my ( $self, $module ) = @_;
  for my $backend ( @{ $self->backend_resolve_order } ) {
    my $instance = $self->_usable_backend(
      'Resolver',
      $backend,
      [
        _backend_get    => sub { $self->backend_http->get(@_) },
        _backend_mirror => sub { $self->backend_http->mirror(@_) },
      ]
    );
    my $result = $instance->resolve($module);
    if ( not $result ) {
      _carpf( "'resolver' backend %s got no result trying next", $backend );
      next;
    }
    return $result;
  }
  _carp("None of the specified backends returned a result");
  return;

}
1;
