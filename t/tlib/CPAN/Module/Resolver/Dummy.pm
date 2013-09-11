
use strict;
use warnings;

package CPAN::Module::Resolver::Dummy;

# ABSTRACT: Dummy example resolver.

use Class::Tiny;
use Role::Tiny::With qw( with );

sub usable      { 1 }
sub can_resolve { 1 }

sub resolve {
  require CPAN::Module::Resolver::Result;
  return CPAN::Module::Resolver::Result->new();
}

with 'CPAN::Module::Resolver::Role::Resolver';

1;

