
use strict;
use warnings;

package CPAN::Module::Resolver::Lookup;

# ABSTRACT: A container for a C<look-up> query

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"CPAN::Module::Resolver::Lookup",
    "interface":"class",
    "inherits":"Class::Tiny::Object"
}

=end MetaPOD::JSON

=cut

=head1 SYNOPSIS

    my $lookup = CPAN::Module::Resolver::Lookup->latest_by_module('Moose');
    my $result = SOME_LOOKUP_ENGINE->resolve($lookup);

=cut

=attr C<module>

=cut

use Class::Tiny (qw( module )), {};

=method C<latest_by_module>

    my $instance = ::Lookup->latest_by_module('Moose');

=cut

sub latest_by_module {
  return $_[0]->new( module => $_[1] );
}

1;
