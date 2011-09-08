package Conifer::Page;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;

# This action will render a template
sub index {
	$|=1;
	my $self = shift;
	my $user = $self->session('name');
	#~ $user = &check_user( $user )->{"login"} ? $user : 'Anonymous' ;
	
	#~ print Data::Dumper::Dumper(Conifer->redis);
	#~ my $a = Conifer->redis->set(key => 'value');
	#~ my $b = Conifer->redis->get("key");
	#~ print "a: $a$b";
	
	$self->render(user => $user);
	#~ $self->render(message => "Welcome to Re.fer.To!");
	
}

1;
