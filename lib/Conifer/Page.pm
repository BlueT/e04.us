package Conifer::Page;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;

# This action will render a template
sub index {
	$|=1;
	my $self = shift;
	$self->redirect_to('http://'.$self->req->url->base->host);
	#~ my $user = $self->session('name');
	#~ $user = &check_user( $user )->{"login"} ? $user : 'Anonymous' ;
	
	#~ print Data::Dumper::Dumper(Conifer->redis);
	#~ my $a = Conifer->redis->set(key => 'value');
	#~ my $b = Conifer->redis->get("key");
	#~ print "a: $a$b";
	
	#~ print Dumper($self->req->url->base->host);
	
	#~ $self->render(user => $self->req->url->host);
	#~ $self->render(message => "Welcome to Re.fer.To!");
	
}

sub new_fuck {
	my $self = shift;

	#~ my $word = $self->param('word');
	
	my $motd = "A Fuck A Day, keeps the doctor away.";
	
	$self->render(motd => "$motd");
}

sub echo {
	my $self = shift;

	my $word = $self->param('word');
	# Render template "example/welcome.html.ep" with message
	$self->render(message => "$word");
}

sub list {
	# 幹 $whom 的人
	# 對 $whom 的幹
	# $whom 幹的人
	# $whom 的反擊
}

1;
