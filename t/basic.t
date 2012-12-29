use strict;
use warnings;

use Test::More;

use CPAN::Module::Resolver;

my $resolver = CPAN::Module::Resolver->new( );

pass('constructor did not bail');


my $content = $resolver->_get( 'http://google.com' );


done_testing();

