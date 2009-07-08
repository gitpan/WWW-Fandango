package WWW::Fandango::Showtime;

use Moose;
use Modern::Perl;

has 'theater' => (
	is => 'rw',
	isa => 'WWW::Fandango::Theater',
);

has 'movie' => (
	is => 'rw',
	isa => 'WWW::Fandango::Movie',
);

has 'url' => (
	is => 'rw',
	isa => 'Str',
	# reader => { 'url' => sub { URI->new(shift)->as_string } },
);	

has 'datetime' => (
	is => 'rw',
	isa => 'DateTime'
);

no Moose;
__PACKAGE__->meta->make_immutable;