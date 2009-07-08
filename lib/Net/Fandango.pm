package WWW::Fandango;

use Moose;
use Modern::Perl;
use Data::Dumper;
use WWW::Mechanize;
use HTML::TreeBuilder;

our $VERSION = '0.0.1.1';

# wha!

# I stole most of this from Net::Twitter
around BUILDARGS => sub {
	my $m = shift; my $self = shift;
	
	my $args = $self->$m(@_);
	
	my $fandango_defaults = delete $args->{fandango_defaults} || {
		fandango_uri => "http://www.fandango.com",
	};
	
	return {
		%$fandango_defaults, %$args
	}
};

has 'fandango_uri' => (
        isa    => 'Str', is => 'rw', required => 1,
);

has 'mech' => (
	is => 'ro',
	builder => '_mech',	
);

has 'p' => ( # p stands for parser: HTML::TreeBuilder
	is => 'ro',
	builder => '_p',
);

sub _p {
	my $p = HTML::TreeBuilder->new;
	$p;
};

sub _mech {
	my $mech = WWW::Mechanize->new;
	$mech->timeout(10);
	$mech;
}

no Moose;
__PACKAGE__->meta->make_immutable;

=head1 NAME

WWW::Fandango - Perl interface for the Fandango website

=head1 AUTHOR

David Moreno, david@axiombox.com.
