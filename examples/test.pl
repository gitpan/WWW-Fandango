#!/usr/bin/perl

use Modern::Perl;
use Data::Dumper;
use WWW::Fandango::Search;
use WWW::Fandango::Location;

my $m = WWW::Fandango::Movie->new(
	id => 'transformers:revengeofthefallen_111307'
);

$m->location(
	WWW::Fandango::Location->new(zip => 10039)
);

$m->date(
	DateTime->now->add(days => 1)
);

print Dumper $m->showtimes();

# for my $movie ($s->movies) {
# 	say "URL: ".$movie->url;
# 	say $movie->title;
# 	say $movie->description;
# 	say "";
# }
# 
# # print Dumper $m;