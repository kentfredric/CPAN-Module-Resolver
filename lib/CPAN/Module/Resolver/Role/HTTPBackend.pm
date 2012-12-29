#
#===============================================================================
#
#         FILE: HTTPBackend.pm
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 12/30/12 02:22:19
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

package CPAN::Module::Resolver::Role::HTTPBackend;

use Moo::Role;

requires 'get';
requires 'mirror';
requires 'usable';

1; 

