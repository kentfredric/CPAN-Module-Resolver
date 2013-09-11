
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

use Class::Tiny (qw( module )), {};

sub latest_by_module {
  return $_[0]->new( module => $_[1] );
}

1;
