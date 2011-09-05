package ReFerTo::Page;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub index {
	my $self = shift;
	my $user = $self->session('name');
	#~ $user = &check_user( $user )->{"login"} ? $user : 'Anonymous' ;
	
	$self->render(user => $user);
	#~ $self->render(message => "Welcome to Re.fer.To!");
	
}

1;
