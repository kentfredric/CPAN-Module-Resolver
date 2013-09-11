
use strict;
use warnings;

use Test::More;
use lib 't/tlib';
use InstanceTests;

my $class = 'CPAN::Module::Resolver::Lookup';
use_ok($class);

$class->method_test(
  'latest_by_module' => ['Moose'] => sub {
    my $result = shift;
    $result->call_is( 'module', [], 'Moose' );
  }
);
$class->instance_test(
  [ module => 'Moose' ] => sub {
    my $result = shift;
    $result->call_is( 'module', [], 'Moose' );
  }
);
done_testing;

