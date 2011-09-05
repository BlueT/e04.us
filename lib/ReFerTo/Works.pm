package ReFerTo::Works;
use Mojo::Base 'Mojolicious::Controller';

#~ works list / order / buy:
    #~ * show all works
    #~ * choose which one to buy, and how many copies
    #~ * show how much money it (this item) costs
    #~ * a link to check the work
    #~ * delete the work
    #~ * save to "my chart" when done. -- by BlueT 

sub list {
	my $self = shift;
	my $user = $self->session('name');
	if (not &check_user( $user )->{"login"}) {
		$self->flash(message => 'Please login first!');
		$self->redirect_to('login');
	}
	
	if (my $del = $self->param('del')) {
		# FIXME:
		# delete the card_set and all cards within it
	}
	
	if ($self->param('new')) {
		# FIXME:
		# insert DB a card_set and 30 cards
	}
	
	# FIXME:
	# get info of all works
	# card_set id
	my @card_sets = ("card_set_id", "name or desc");
	
	# FIXME:
	# get card_set price from card_set id
	my @card_set_price = ("card_set_id", "price");
	
	# generate link to each work
	# if user wanna buy, post card_set_id and copies to "my_chart"
	return $self->render(card_sets => \@card_sets);
}

1;
