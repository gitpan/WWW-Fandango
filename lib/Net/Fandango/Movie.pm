package WWW::Fandango::Movie;

use Moose;
use Modern::Perl;
use Data::Dumper;
use autodie qw(:all);
use WWW::Fandango::Showtime;
use WWW::Fandango::Theater;

# wha!
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
		$movie->fandango_uri . '/' . $movie->id . '/'. $movie->type_url;
	}
);

has 'type_url' => (
	is => 'rw',
	lazy => 1,
	default => 'movieoverview',
);

has 'title' => (
	is => 'rw',
	lazy => 1,
	default => sub {
		my($movie) = shift;
		
		if($movie->type_url eq 'summary') {
			$movie->movieoverview->find('title')->as_text =~ m!(.+?) Synopsis$!;
			return $1;
		} else {
			$movie->movieoverview->look_down(
				_tag => 'li',
				class => 'title'
			)->as_trimmed_text;
		};
		
		# croak "Issues getting title on ".$movie->url if $@;
	}
);

has 'location' => (
	is => 'rw',
	isa => 'WWW::Fandango::Location',
);

has 'date' => (
	is => 'rw',
	isa => 'DateTime',
);

has 'showtimes' => (
	is => 'ro',
	lazy => 1,
	builder => '_get_showtimes',
);

has 'showtimes_url' => (
	is => 'ro',
	lazy => 1,
	default => sub {
		my $url = $_[0]->url;
		$url =~ s/\/\w+?$//;
		$url .= '/movietimes?location='.$_[0]->location->zip.'&date='.$_[0]->date->strftime("%m/%d/%Y");
	}
);

sub _get_showtimes {
	my($movie) = shift;
	
	croak "No location defined." unless $movie->location;
	croak "No date defined." unless $movie->date;
	
	$movie->mech->get($movie->showtimes_url);
	
	my $t = $movie->p->parse( $movie->mech->content );
	
	my @theaters;
	for my $t ($t->look_down('_tag' => 'div', 'class' => qr/^theater (?:non)?wired/i)) {
		my $h3 = $t->find('h3');
		
		my $name = $h3->as_text;
		
		$h3->find('a')->attr('href') =~ m!fandango\.com/(.+?)/theaterpage!;
		my $id = $1;
		
		push @theaters, [$id, $name];
	}
	
	my @times; my @showtimes; my $count = 0;
	
	for my $t ($t->look_down('_tag' => 'div', 'class' => 'times')) {
		my @showtimes;	
		for my $i ($t->look_down('_tag' => 'li')) {
			
			my $showtime;
			if(my $span = $i->find('span')) {
				$showtime = $span->as_trimmed_text;
			} else {
				$showtime = $i->as_trimmed_text;
			}
			
			my $showtime_url = qq@#@; # ;-)
			
			if(my $u = $i->find('a')) {
				$showtime_url = $u->attr('href');
			}
			
			my($h, $m, $apm) = $showtime =~ /^(\d{1,2}):(\d{1,2})(am)?$/;
			
			my $new_date = DateTime->new(
				year => $movie->date->year,
				month => $movie->date->month,
				day => $movie->date->day,
				# haxor!
				hour => $apm && $h == 12 ? '0' : ($apm ? $h : $h == 12 ? 12 : $h + 12),
				minute => $m
			);
			
			# this is so hackerish that i'm almost proud
			if($apm and ($h == 12 or $h < 7)) {
				$new_date->add(days => 1);
			}
			
			push @showtimes, 
				WWW::Fandango::Showtime->new(
					url 		=> $showtime_url,
					# datetime => '12:34:56'
					datetime 	=> $new_date,
					# movie 		=> $movie,
					# theater 	=> WWW::Fandango::Theater->new(id => $theaters[$count]->[0]),
				);
			
			# print Dumper $i->as_HTML;
		}
		push @{ $theaters[$count] }, \@showtimes;
		$count ++;
	}
	
	\@theaters;
	
};

has 'description' => (
	is => 'rw',
	lazy => 1,
	default => sub {
		my($movie) = shift;
				
		if($movie->type_url eq 'summary') {
			my $syn = $movie->movieoverview->look_down(
				_tag => 'div',
				class => 'tab-content',
			)->find('p');
			
			defined $syn ? $syn->as_text : qq\\;
		} else {
		
		# syn => synopsis
			my $syn = $movie->movieoverview->look_down(
				'_tag' => 'li',
				'class' => 'synopsis'
			);
		
			eval { # fandango might change this
				$syn->look_down(
					'_tag' => 'a',
					'id' => 'read_more'
				)->delete;
			};
			
			if (defined $syn) {
				$syn->as_trimmed_text;
			} else {
				qq//;
			}
		}

	}
);

has 'movieoverview' => (
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
