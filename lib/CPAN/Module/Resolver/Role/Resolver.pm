
use strict;
use warnings;

package CPAN::Module::Resolver::Role::Resolver;

# ABSTRACT: An interface for module resolving for CPAN::Module::Resolver

use Moo::Role;

=head1 DESCRIPTION

	my $resolver = SomeResolver->new(
		_backend_get => sub { },
		_backend_mirror => sub { },
	);
	return unless $resolver->usable();
	my $result = $resolver->resolve('Moo::Role');
	if( $result ){
		Data::Dump::pp( $result->as_hash );
	}


=carg _get

Must be a C<CODEREF> that returns a string when given a URI.

	->new(
		_backend_get => sub {
			my ( $uri ) = @_;
			...
			return $string;
		},
		...
	);

=pattr _get

=cut

has _get => ( is => rwp => required => 1 );

=carg _mirror

Must be a C<CODEREF> that copies a given URI to the specified local path.

	->new(
		_backend_mirror => sub {
			my ( $uri , $dest ) = @_;
			...
			return 1;
		},
		...
	);


=pattr _mirror

=cut

has _mirror => ( is => rwp => required => 1 );

=rrequire resolve


	$backend->resolve( $module )->isa('CPAN::Module::Resolver::Result')

=over 4

=item * Must take a single argument, module name

=item * must return a L<<< C<< CPAN::Module::Resolver::B<Result> >> object|CPAN::Module::Resolver::Result >>>

=back


=cut

requires resolve =>;

=method get

	$self->get( $uri );

Convenience method to call accessor-stored coderef in C<_backend_get>

=method mirror

	$self->mirror( $uri, $path );

Convenience method to call accessor-stored coderef in C<_backend_mirror>

=cut

sub get    { my $self = shift; $self->_get->(@_) }
sub mirror { my $self = shift; $self->_mirror->(@_) }

1;
