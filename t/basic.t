use strict;
use warnings;

use Test::More;

use CPAN::Module::Resolver;

my $resolver = CPAN::Module::Resolver->new( backend_resolve_order => [ 'search_cpan_org' ] );

pass('constructor did not bail');

my $result = $resolver->resolve('Moose');

pass('didn\'t bail resolving a module');

note explain $result;

done_testing();

