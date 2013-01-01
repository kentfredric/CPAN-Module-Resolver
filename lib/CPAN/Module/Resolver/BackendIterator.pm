use strict;
use warnings;

package CPAN::Module::Resolver::BackendIterator;
use Moo;
use Carp qw( croak carp );
use Module::Runtime;
use Try::Tiny;

sub _carpf { my $format = shift; return carp( sprintf $format, @_ ) }
sub _array_ref { ref $_[0] eq 'ARRAY' or croak('must be an array ref') }
sub _module_name { Module::Runtime::check_module_name($_[0]) }
sub _hash_ref { ref $_[0] eq 'HASH' or croak('must be a hash ref') }

has order            => ( is => lazy =>, isa => \&_array_ref );
has args             => ( is => lazy =>, isa => \&_hash_ref );
has common_args      => ( is => lazy =>, isa => \&_array_ref );

has label          => ( is => rwp =>, required => 1 );
has backend_prefix => ( is => rwp =>, required => 1, isa => \&_module_name );

sub _build_common_args { [] }

sub _expand_backend {
  my ( $self, $backend ) = @_;
  return Module::Runtime::compose_module_name( $self->backend_prefix, $backend );
}

sub _load_backend {
  my ( $self, $backend ) = @_;
  my $modname = $self->_expand_backend($backend);
  return try {
    Module::Runtime::require_module($modname);
   _carpf( qq{'%s' backend %s loaded}, $self->label, $backend);
    return $modname;
  }
  catch {
    _carpf( qq{'%s' backend %s failed to load, trying next\n\n%s\n\n}, $self->label, $backend, $_ );
    return;
  };
}

sub _usable_backend_instance {
  my ( $self, $backend ) = @_;
  my $modname = $self->_load_backend($backend);
  return unless $modname;
  my (@args) = @{ $self->common_args };
  if ( exists $self->args->{$backend} ) {
    push @args, @{ $self->args->{$backend} };
  }
  my $instance = $modname->new(@args);
  if ( not $instance->usable() ) {
    _carpf( q{'%s' backend %s unusable, trying next}, $self->label, $backend );
    return;
  }
   _carpf( qq{'%s' backend %s in use}, $self->label, $backend);
  return $instance;
}

sub each_usable_backend {
  my ( $self, $code ) = @_;
  for my $backend ( @{ $self->order } ) {
    my $instance = $self->_usable_backend_instance($backend);
    next unless $instance;
    local $_ = $instance;
    my $result = $code->($instance);
    if ($result) {
      return $result;
    }
  }
  _croak(q{None of the specified backends were loadable/useable});
}

1;
