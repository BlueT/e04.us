package Conifer::Page;
use utf8;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;


sub index {
	$|=1;
	my $self = shift;
	
	$self->render(motd => "你今天幹勦了嗎？ / Have you Fuck^H^H^Horked somebody today?");
	
}

sub new_fuck {
	my $self = shift;
	my $who = $self->session('who') || '我';
	
	my $motd = "A Fuck A Day, keeps the doctor away.";
	
	$self->render(motd => "$motd", who => "$who");
}

sub echo {
	my $self = shift;

	my $word = $self->param('word');
	
	$self->render(message => "$word");
}

sub list {
	# 幹 $whom 的人
	# 對 $whom 的幹
	# $whom 幹的人
	# $whom 的反擊
}

1;
