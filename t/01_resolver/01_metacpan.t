
use Test::More;
use FindBin;

use CPAN::Module::Resolver::Backend::metacpan;

my $responses = {
  'http://api.metacpan.org/module/Moose'  => 'module_Moose',
  'http://api.metacpan.org/release/Moose' => 'release_Moose',
};

my $queried = {};

my $instance = CPAN::Module::Resolver::Backend::metacpan->new(
  _backend_get => sub {
    my ($uri) = @_;
    $queried->{$uri}++;
    if ( defined $responses->{$uri} ) {
      my $fn  = $responses->{$uri};
      my $ffn = "$FindBin::Bin/data/metacpan/$fn";
      open my $fh, '<', "$ffn" or die "No such file $ffn  ( $! )";
      local $/;
      return <$fh>;
    }
    return;
  },
  _backend_mirror => sub { },
);

ok( $instance->usable(), 'instance is usable' );

my $result = $instance->resolve('Moose');
ok( $result, 'Got a result for query Moose' );
for my $uri ( sort keys %{$responses} ) {
  ok( $queried->{$uri}, "Queried $uri" );
}
is( 'Moose-2.0604', $result->distvname, 'distvname is right' );

done_testing;
