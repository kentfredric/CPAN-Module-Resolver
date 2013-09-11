
use strict;
use warnings;

package CPAN::Module::Resolver::Role::Resolver;

# ABSTRACT: An interface for module resolving for CPAN::Module::Resolver

use Role::Tiny;

requires 'usable';         # If the class is generally usable
requires 'can_resolve';    # ->can_resolve(lookup) should be useable
requires 'resolve';        # ->resolve(lookup) should return a result

1;
