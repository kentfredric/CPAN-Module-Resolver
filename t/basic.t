use strict;
use warnings;

use Test::More;

use CPAN::Module::Resolver;

my $resolver = CPAN::Module::Resolver->new();    # backend_resolve_order => [qw( metacpan )] );

pass('constructor did not bail');

my $result = $resolver->resolve('Moo::Role');

pass('didn\'t bail resolving a module');

$result->_distname_info;
if ( $result->has_module_version ) {
  fail("CANT HAVE A VERSION FOR MOO ROLE!");
}
note explain $result->as_hash;

done_testing();

