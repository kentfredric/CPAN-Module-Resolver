
use strict;
use warnings;

use Test::More;
use lib 't/tlib';
use InstanceTests;

use_ok('CPAN::Module::Resolver::Dummy');
use_ok('CPAN::Module::Resolver::Lookup');

my $lookup = CPAN::Module::Resolver::Lookup->latest_by_module('Moose');

my $class = 'CPAN::Module::Resolver::Dummy';
$class->instance_test(
  [] => sub {
    my $resolver = shift;
    $resolver->call_ok( 'usable', [] );
    $resolver->call_ok( 'can_resolve', [$lookup] );
    $resolver->method_test(
      'resolve',
      [$lookup],
      sub {
        my $result = shift;
        isa_ok( $result, 'CPAN::Module::Resolver::Result' );
      }
    );
  }
);
done_testing;

