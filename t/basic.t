use strict;
use warnings;

use Test::More;

use CPAN::Module::Resolver;

my $resolver = CPAN::Module::Resolver->new( );

pass('constructor did not bail');

my $result = $resolver->resolve('Moose');

pass('didn\'t bail resolving a module');

note explain $result;

done_testing();

