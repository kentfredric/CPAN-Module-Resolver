
use strict;
use warnings;

package CPAN::Module::Resolver::Backend::Resolver::metacpan;

use Moo;
with 'CPAN::Module::Resolver::Role::Resolver';

sub resolve {
  my ( $self, $modname ) = @_;
  require JSON::PP;
  
  my $module_uri  = "http://api.metacpan.org/module/$module";
  my $module_json = $self->get($module_uri);
  my $module_meta = eval { JSON::PP::decode_json($module_json) };
  if ( $module_meta && $module_meta->{distribution} ) {
    my $dist_uri  = "http://api.metacpan.org/release/$module_meta->{distribution}";
    my $dist_json = $self->backend_http->get($dist_uri);
    my $dist_meta = eval { JSON::PP::decode_json($dist_json) };
    if ( $dist_meta && $dist_meta->{download_url} ) {
      ( my $distfile = $dist_meta->{download_url} ) =~ s!.+/authors/id/!!;
      local $self->{mirrors} = $self->{mirrors};
      if ( $dist_meta->{stat}->{mtime} > time() - 24 * 60 * 60 ) {
        $self->{mirrors} = ['http://cpan.metacpan.org'];
      }
      return $self->cpan_module( $module, $distfile, $dist_meta->{version} );
    }
  }
  return;
}
