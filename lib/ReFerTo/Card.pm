package ReFerTo::Card;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub edit {
	my $self = shift;
	my $user = $self->session('name');
	if (not &check_user( $user )->{"login"}) {
		$self->flash(message => 'Please login first!');
		$self->redirect_to('login');
	}
	
	my $card_seq = $self->param('card id') || '';
	my $picid = $self->param('pic_id') || '';
	if ($picid) {
		# FIXME:
		# store (card_id, pic) mapping
		$self->flash(message => 'Saved.');
		$self->redirect_to('card_set_edit');
	}
	
	# FIXME:
	# Get file id and names from DB
	my %images = {"name" => "id"};
	
	# Sort by new order
	my @images_sorted = sort {$b cmp $a} keys %images;
	
	return $self->render(images_sorted => \@images_sorted, images => \%images, image_base => $IMAGE_BASE, card_seq => $card_seq);
}

sub card_set {
	# when a user wanna edit a card set,
	# he come to here first,
	# click the empty card and then going to /card_edit
	
	my $self = shift;
	my $user = $self->session('name');
	if (not &check_user( $user )->{"login"}) {
		$self->flash(message => 'Please login first!');
		$self->redirect_to('login');
	}
	
	# FIXME:
	# get info of a card_set
	# card id, seq, picid
	my @card_seq = ("card_seq","card_id");
	my %card_info = {"card_id","pic_id"};
	
	return $self->render(card_seq => \@card_seq, card_info => \%card_info);
}

1;
