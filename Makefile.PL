# @(#) $Id: Makefile.PL,v 1.1 2003/03/27 15:00:26 dom Exp $
use 5.006001;

use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Class::DBI::ToSax',
    VERSION_FROM => 'ToSax.pm',
    PREREQ_PM    => {
        'Class::Data::Inheritable' => 0,
        'NEXT'                     => 0,
    },
);

# Local Variables:
# mode: cperl
# cperl-indent-level: 4
# indent-tabs-mode: nil
# End:
# vim: set ai et sw=4 :
