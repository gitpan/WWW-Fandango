package WWW::Fandango::Search;

use Moose;
use Modern::Perl;
use Data::Dumper;

use WWW::Fandango::Movie;

extends 'WWW::Fandango';

has 'url' => (
	is => 'ro',
	lazy => 1,
	default => sub {
		my($movie) = shift;
		$movie->fandango_uri . '/GlobalSearch.aspx?';
	}
);

has 'query' => (
	is => 'rw',
	isa => 'Str',
	required => 1,
);

sub movies {
	my($search) = shift;
		
	map {
		WWW::Fandango::Movie->new(
			id 			=> $_->[0], 
			type_url 	=> $_->[2], 
			title 		=> $_->[1]
		)
	} $search->search_on('Movies');
	
}

sub search_on {
	my($search) 	= shift;
	my($on) 		= shift;
	
	my $search_url = $search->url . 'q=' . $search->query .'&repos='.$on;
	
	$search->mech->get($search_url);
	
	my $t = $search->p->parse( $search->mech->content );
	
	my $results = []; my(@featured) = (); my(@others) = ();
	
	eval {
		@featured = $t->look_down('_tag', 'ul', 'class', 'callout')->look_down('_tag' => 'h4');
	};
	eval {
		@others = $t->look_down('_tag', 'ul', 'class', 'results')->look_down('_tag'=>'h5');
	};
	
	push @$results, [$_->look_down('_tag'=>'a')->attr('href'), $_->as_text] for @featured, @others;
	
	my $real = [];
	for my $res (@$results) {
		my($id, $movie_type) = $res->[0] =~ /www\.fandango\.com%2f(.+?)%2f(summary|movieoverview)$/;
		$id =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
		push @$real, [$id, $res->[1], $movie_type] unless grep { $_->[0] eq $id } @$real;
	}
	
	@$real;
}

no Moose;
__PACKAGE__->meta->make_immutable;