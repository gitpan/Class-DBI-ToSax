package Class::DBI::ToSax;
# @(#) $Id: ToSax.pm,v 1.2 2003/03/27 15:01:07 dom Exp $

# There's a bug in UNIVERSAL::isa() in 5.6.0 :(
use 5.006001;
use strict;
use warnings;

our $VERSION = '0.01';

use base qw( Class::Data::Inheritable );

use Carp qw( croak );
use NEXT;

sub _emit_sax_value {
    my $self = shift;
    my ( $handler, $col, $val ) = @_;
    if ( ref( $val ) && $val->can( 'to_sax' ) ) {
        $val->to_sax( $handler );
    } else {
        $handler->start_element( { Name => $col } );
        $val = '' if !defined $val || length $val == 0;
        $handler->characters(  { Data => $val } );
        $handler->end_element( { Name => $col } );
    }
}

our %seen;
sub to_sax {
    my $self = shift;
    my $class = ref $self;
    my ( $handler ) = @_;
    die "usage: to_sax(handler)\n"
        unless $handler && ref $handler && $handler->can( 'start_element' );

    # Ensure that we never have the same class twice in the call stack.
    return if $seen{ $class };
    local %seen = %seen;
    $seen{ $class }++;

    my $pk = $self->primary_column;
    $handler->start_element( {
        Name => $self->table,
        Attributes => {
            '{}id' => { Name => 'id', Value => $self->$pk },
        },
    } );

    foreach my $col ( sort grep { $_ ne $pk } $self->columns ) {
        $self->_emit_sax_value( $handler, $col, $self->$col );
    }

    foreach my $col ( sort @{ $self->_has_many_methods || [] } ) {
        my @vals = $self->$col;
        $self->_emit_sax_value( $handler, $col, $_ )
            foreach @vals;
    }

    $handler->end_element( { Name => $self->table } );
}

__PACKAGE__->mk_classdata( '_has_many_methods' );

# Override has_many() so that we can capture the method name.
sub has_many {
    my $class = shift;
    my ( $method ) = @_;
    my $method_list = $class->_has_many_methods || [];
    push @$method_list, $method;
    $class->_has_many_methods( $method_list );
    return $class->NEXT::has_many( @_ );
}

1;
__END__

=head1 NAME

Class::DBI::ToSax - turn database objects to SAX events

=head1 SYNOPSIS

  package My::DBI;
  # NB!  Must come first in inheritance chain!
  use base qw( Class::DBI::ToSax Class::DBI );

  # In the application...
  use XML::SAX::Writer;
  my $obj = My::DBI->retrieve( $x );
  my $w = XML::SAX::Writer->new;
  $w->start_document;
  $obj->to_sax( $w );
  $w->end_document;

=head1 DESCRIPTION

This module adds an extra method to Class::DBI, to_sax().  This method accepts
an XML::SAX handler, and will use it to output a representation of the object
in XML form, by calling methods on the handler.  All the usual sorts of SAX
handler can be passed in.  The example above shows a writer to send the XML to
stdout.

B<NB>: This class must come first in the inheritance chain because it
overrides ordinary Class::DBI methods.

The generated XML will have:

=over 4

=item *

One wrapper element, which is the name of the table, with an I<id>
attribute.

=item *

One containing element for each column which has a scalar value.

=item *

One element for each has_a() relationship, which will be nested.

=item *

Zero or more elements for each has_many() relationship, each of which
will be nested.

=back

=head1 SEE ALSO

L<Class::DBI>, L<XML::SAX>, L<XML::SAX::Writer>.

If you want to generate XML directly from the database without using
Class::DBI, look at L<XML::Generator::DBI>.

=head1 BUGS

start_document() and end_document() should be called by us, not the
user.

We should be able to flag some fields as containing CDATA.  I'm not sure
of the best interface to do this, however.

=head1 AUTHOR

Dominic Mitchell, E<lt>cpan@semantico.com<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by semantico

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. 

=cut

# vim: set ai et sw=4 :
