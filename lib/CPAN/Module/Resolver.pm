use strict;
use warnings;

package CPAN::Module::Resolver;
use Moo;
use Try::Tiny;

has backend_resolve_order => ( is => lazy => );
has backend_http_order     => ( is => lazy => );
has backend_http           => ( is => lazy => );


sub _get { my $self = shift; return $self->backend_http->get(@_) }
sub _mirror { my $self = shift; return $self->backend_http->mirror(@_)}

sub _build_backend_resolve_order { return [qw( cpandb )]; }
sub _build_backend_http_order     { return [qw( LWP wget curl HTTP::Tiny )] }

sub _carp { require Carp; return Carp::carp(@_) }
sub _carpf { my $format = shift; return _carp( sprintf $format, @_ ) }
sub _croak { require Carp; return Carp::croak(@_) }

sub _build_backend_http {
  my ($self) = shift;
  require Module::Runtime;
  for my $backend ( @{ $self->backend_http_order } ) {
	my $do_next;

    my $modname = Module::Runtime::compose_module_name( 'CPAN::Module::Resolver::Backend::HTTP', $backend );

	try {
		Module::Runtime::require_module($modname);
	} catch {
		_carpf( "'http' backend %s/%s failed to load, trying next\n\n%s\n\n", $backend, $modname, $_ );
		$do_next = 1;
	};
	next if $do_next;
	my $instance = $modname->new();
    if ( not $instance->usable() ) {
      _carpf( "'http' backend %s/%s unusable, trying next", $backend, $modname );
    }
    return $instance;
  }
  _croak("None of the specified backends were loadable/useable");
}




1;
