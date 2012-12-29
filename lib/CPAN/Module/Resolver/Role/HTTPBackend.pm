use strict;
use warnings;

package CPAN::Module::Resolver::Role::HTTPBackend;
# ABSTRACT: An interface for adapters to implement various HTTP functions for CPAN::Module::Resolver

use Moo::Role;

=head1 DESCRIPTION

	my $foo = SomeBackend->new();

	return unless $foo->usable();

	my $result = $foo->get('example.com/some/url');

	$foo->mirror('example.com/some/url','/tmp/output');


=rrequire get

Fetch a URL in the program.

=over 4

=item * takes a URL

=item * returns that URLs content as a string

=back

	my $result = Backend->new()->get( $url );


=rrequire mirror

Mirror a URL to disk

=over 4

=item * takes a URL and a target path

=item * stores the content of that URL in the designated path

=item * returns success status

=back

	if( Backend->new()->mirror( $url, $target ) ){ 
		 # do stuff with $target
	}

=rrequire usable

Determine if the backend is usable or not.

=over 4

=item * takes no arguments

=item * return true ( defined and not zero ) on success

=item * returns false ( undef or zero ) on failure

=back

	if( Backend()->new()->usable() ) { 
		# code 
	}

=cut

requires 'get';
requires 'mirror';
requires 'usable';

1; 

