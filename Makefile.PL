# @(#) $Id: Makefile.PL,v 1.2 2003/04/12 21:43:45 dom Exp $
use 5.006001;

use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Class::DBI::ToSax',
    VERSION_FROM => 'ToSax.pm',
    PREREQ_PM    => {
        # Both of these are required by Class::DBI, so shouldn't be too
        # onerous...
        'Class::Accessor'          => 0,
        'Class::Data::Inheritable' => 0,
        # DCONWAY rocks.
        'NEXT'                     => 0,
        # Most people will want this and it's good for testing.
        'XML::SAX::Writer'         => 0,
    },
);

# Local Variables:
# mode: cperl
# cperl-indent-level: 4
# indent-tabs-mode: nil
# End:
# vim: set ai et sw=4 :
