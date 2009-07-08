package WWW::Fandango::Theater;

use Moose;

extends 'WWW::Fandango';

has 'id' => (
	is => 'rw',
	required => 1,
);

has 'url' => (
	is => 'ro',
	lazy => 1,
	default => sub {
		my($movie) = shift;
		$movie->fandango_uri . '/' . $movie->id . '/theaterpage';
	}
);

has 'name' => (
	is => 'ro',
	lazy => 1,
	default => sub {
		
		$_[0]->theaterpage->look_down(
			'_tag' => 'div', 'class' => 'info'
		)->look_down('_tag' => 'a')->as_trimmed_text;
		
	}
);

has 'address' => (
	is => 'ro',
	lazy => 1,
	default => sub {
		$_[0]->theaterpage->look_down(
			'_tag' => 'div', 'class' => 'info'
		)->look_down('_tag' => 'p')->as_trimmed_text;
	}
);

has 'map_url' => (
	is => 'ro',
	lazy => 1,
	default => sub {
		
		# haxor!
		$_[0]->theaterpage->look_down(
			'_tag' => 'div', 'class' => 'info'
		)->look_down(
			'_tag' => 'a', 'rel' => 'nofollow', 'href' => qr/maps/
		)->attr('href') =~ /(http.+?)'/;
		$1;
		
	}
);

has 'theaterpage' => (
	is => 'ro',
	lazy => 1,
	default => sub {
		my($movie) = shift;
		
		$movie->mech->get( $movie->url );
		
		my $e = $movie->p->parse( $movie->mech->get->content);
		
		$e;
	}
	
);

no Moose;
__PACKAGE__->meta->make_immutable;