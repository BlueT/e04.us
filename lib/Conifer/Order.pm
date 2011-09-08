package ReFerTo::Order;
use Mojo::Base 'Mojolicious::Controller';

#~ confirm order:
#~ 
    #~ * show order info
    #~ * a place to input last 5 digits of users bank account
sub confirm {
	my $self = shift;
	my $user = $self->session('name');
	if (not &check_user( $user )->{"login"}) {
		$self->flash(message => 'Please login first!');
		$self->redirect_to('login');
	}
	
	my $five_digits = $self->param('5digits');
	
	if ($five_digits) {
		# FIXME:
		# update DB with the 5 digits
		$self->flash(message => "Thanx for ordering");
		$self->redirect_to('order_list');
	}
	
	# FIXME:
	# get list of items user's going to buy, how much for each and how much in total
	my %works_buy = ("card_set id" => (desc => "desc", price => "price"));
	my $total_price;
	$total_price += $works_buy{"$_"}{"price"} for keys %works_buy;
	# FIXME:
	# got work id, show total_price
	return $self->render(works_buy => \%works_buy, total_price => $total_price);
}


#~ order list:
#~ 
    #~ * list all orders
          #~ o order id
          #~ o pic_group_name
          #~ o create_time
          #~ o order_total_price
          #~ o order_status
          #~ o check detail 
sub list {
	my $self = shift;
	my $user = $self->session('name');
	if (not &check_user( $user )->{"login"}) {
		$self->flash(message => 'Please login first!');
		$self->redirect_to('login');
	}
	
	# FIXME:
	# get those info
	my %order_list;
	
	return $self->render(order_list => \%order_list);
}


#~ order detail:
#~ 
    #~ * edit / cancel / archive
    #~ * user info
    #~ * order_bank_5digits
    #~ * work_id
    #~ * copies
    #~ * price
    #~ * 封面夾心 -- WTF?!
    #~ * order status
    #~ * 出貨資訊 -- WTF?! 

sub detail {
	# no need
	my $self = shift;
	my $user = $self->session('name');
	if (not &check_user( $user )->{"login"}) {
		$self->flash(message => 'Please login first!');
		$self->redirect_to('login');
	}
}


#~ checkout:
#~ 
    #~ * list all items user's going to buy
          #~ o how much money for each
          #~ o how much in total 
    #~ * 從規格處挑選封面夾心 -- WTF this is?!
    #~ * how to pay
    #~ * what kind of reciept
    #~ * receipt info
          #~ o Title/name
          #~ o phone
          #~ o postal code
          #~ o address 
    #~ * express info
          #~ o same as receipt info
sub checkout {
	my $self = shift;
	my $user = $self->session('name');
	if (not &check_user( $user )->{"login"}) {
		$self->flash(message => 'Please login first!');
		$self->redirect_to('login');
	}
	
	my $pay_method = $self->param('pay_method');
	my $reciept = $self->param('reciept');
	my $s_title = $self->param('s_title');
	my $s_phone = $self->param('s_phone');
	my $s_postal_code = $self->param('s_postal_code');
	my $s_addr = $self->param('s_addr');
	my $r_title = $self->param('r_title');
	my $r_phone = $self->param('r_phone');
	my $r_postal_code = $self->param('r_postal_code');
	my $r_addr = $self->param('r_addr');
	
	if ($pay_method && $reciept && $s_title && $s_phone && $s_postal_code && $s_addr && $r_title && $r_phone && $r_postal_code && $r_addr) {
		$self->flash(message => "Thanx for ordering");
		$self->redirect_to('my_chart');
	}
	
	# FIXME:
	# get list of items user's going to buy, how much for each and how much in total
	my %works_buy = ("card_set id" => (desc => "desc", price => "price"));
	my $total_price;
	$total_price += $works_buy{"$_"}{"price"} for keys %works_buy;
	
	return $self->render(works_buy => \%works_buy, total_price => $total_price);
}

1;
