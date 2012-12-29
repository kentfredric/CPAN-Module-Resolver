use strict;
use warnings;

package CPAN::Module::Resolver::Backend::HTTP::LWP;

# ABSTRACT: Adapter for CPAN::Module::Resolver to use LWP

=head1 DESCRIPTION

This is merely a backend implementation for L<< C<CPAN::Module::Resolver>|CPAN::Module::Resolver >>,
via implementing the role L<< C<CPAN::Module::Resolver::Role::HTTPBackend>|CPAN::Module::Resolver::Role::HTTPBackend >>.

It acts to provide a unified interface for requesting data, and uses LWP to provide this feature.

See the documentation for L<< C<CPAN::Module::Resolver::Role::HTTPBackend>|CPAN::Module::Resolver::Role::HTTPBackend >> for direct usage details.

=cut

=head1 CREDITS

Logic stolen from L<< C<cpanm>|App::cpanminus >>, by L<< Tatsuhiko Miyagawa|https://metacpan.org/author/MIYAGAWA >>

=cut

use Moo;
with 'CPAN::Module::Resolver::Role::HTTPBackend';

has lwp_instance => ( is => lazy => );

sub _version {
  unless ( __PACKAGE__->VERSION ) { return '0' }
}

sub _use_lwp {
  require Module::Runtime;
  Module::Runtime::use_module( 'LWP::UserAgent', '5.802' );
  Module::Runtime::require_module('HTTP::Request');
}

sub _build_lwp_instance {
  _use_lwp();
  return LWP::UserAgent->new(
    parse_head => 0,
    env_proxy  => 1,
    agent      => ( join q{/}, __PACKAGE__, _version ),
    timeout    => 30,
    @_,
  );
}

sub usable {
  return eval { _use_lwp };
}

sub get {
  my $self = shift;
  my $res = $self->lwp_instance->request( HTTP::Request->new( GET => $_[0] ) );
  return unless $res->is_success;
  return $res->decoded_content;
}

sub mirror {
  my $self = shift;
  my $res  = $self->lwp_instance->mirror(@_);
  return $res->code;
}
1;
