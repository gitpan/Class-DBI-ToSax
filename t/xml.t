#!/usr/bin/perl -w
# @(#) $Id: xml.t,v 1.5 2003/07/16 16:26:41 dom Exp $

use strict;

use lib 't';

use Test::More 'no_plan';

use TestClass; # Brings in TestClass::*.
use XML::SAX::Writer;

# Set up some test objects.
my $bar = TestClass::Bar->new(
    bar_id   => 2,
    bar_name => 'barney',
);
my $foo = TestClass::Foo->new(
    foo_id   => 1,
    foo_name => 'fred',
    bar_id   => $bar,
);
my $baz = TestClass::Baz->new(
    baz_id   => 3,
    baz_name => 'wilma',
    foo_id   => $foo,
);

# Just check that our test objects look roughly like what they should...
isa_ok( $foo, 'TestClass::Foo' );
isa_ok( $bar, 'TestClass::Bar' );
isa_ok( $baz, 'TestClass::Baz' );

my $xml_str;
my $w = XML::SAX::Writer->new( Output => \$xml_str );

$bar->to_sax( $w );
is( $xml_str, "<bar id='2'><bar_name>barney</bar_name></bar>", 'basic xml' );

$foo->to_sax( $w );
is(
    $xml_str,
"<foo id='1'><foo_name>fred</foo_name><bar_id id='2'><bar_name>barney</bar_name></bar_id><baz id='3'><baz_name>wilma</baz_name></baz></foo>",
    'has_a() uses column names not table names',
);

my $zot = TestClass::Foo->new( foo_id => 4, foo_name => 'betty' );
$zot->to_sax( $w );
is(
    $xml_str,
    "<foo id='4'><foo_name>betty</foo_name><bar_id /></foo>",
    'empty has_a() looks ok [RT#2362]'
);

#---------------------------------------------------------------------
# Test MCPK support.
#---------------------------------------------------------------------

my $mcpk = TestClass::MCPK->new( id_a => 'eh', id_b => 'bee' );
$mcpk->to_sax( $w );
is(
    $xml_str,
    "<mcpk id='eh/bee' />",
    'MCPK support',
);

# vim: set ai et sw=4 syntax=perl :
