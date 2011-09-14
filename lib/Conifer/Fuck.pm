package Conifer::Fuck;
use Conifer;
use Mojo::Base 'Mojolicious::Controller';
use Time::HiRes 'time', 'gettimeofday';
use Data::Dumper;
use Digest::SHA1 qw(sha1_hex sha1_base64);
use Digest::MD5 qw(md5 md5_hex md5_base64);
use MIME::Base64;

$|=1;

my %hash_table;

# This action will render a template

sub create {
	my $self = shift;
	my ($who, $whom, $fucks) = ($self->param('who'), $self->param('whom'), $self->param('fucks'));
	
	my ($id, $hash) = &_key_gen;
	
	Conifer->redis->set("fucks:$who:$whom:$id:fucks");
	$self->redirect_to("/$who/fuck/$whom:$hash");
}

sub who_fuck_who {
	# /(.who)/fuck/(.whom)
	my $self = shift;
	my $who = $self->param('who') || 'anon';
	my ($whom, $hash) = split/:/,$self->param('whom');
	$whom ||= 'anon';
	
	my $id = &_key_lookup($hash);
	
	my $fucks = Conifer->redis->get("fucks:$who:$whom:$id:fucks");
	$self->render(who => "$who", whom => "$whom", fucks => "$fucks");
}

sub comment {
	my $self = shift;
	my $hash = shift;
	my $list = Conifer->redis->get("comments:$id:list");
}

sub rank {
	
}

sub _key_gen {
	# new id, hash
	my $counter = Conifer->redis->incr("fucks:counter");
	my $hash = encode_base64($counter);
	
	return($counter, $hash);
}

sub _key_lookup {
	# hash -> id
	my $hash = shift;
	my $id = decode_base64($hash);
	$id =~ s/=//g;
	
	return $id;
}

# Old

sub login {
	# $user_passwd eq md5_base64(sha1_hex($pass))
	
	my $self = shift;

	my $user = $self->session('name');
	if ($user) {
		$self->flash(message => 'You had logged in already!');
		$self->redirect_to('index');
	}
	
	my $name = $self->param('name') || '';
	my $pass = $self->param('pass') || '';
	
	return $self->render(message => 'Please Login.') unless ( $name and $pass );
	
	# FIXME:
	# check in DB, set to memcached
	
	#~ my $sth = $dbh->prepare("
		#~ SELECT user_id
		#~ FROM T_user
		#~ WHERE user_code='$name' AND 
		      #~ user_passwd='$pass';
	#~ ");
	#~ $sth->execute();
	#~ my $ref = $sth->fetchrow_arrayref;
	#~ my $user_id = ${$ref}[0] if $ref;
	#~ $sth->finish();
	#~ 
	#~ print "USER ID: $user_id\n";
	
	#~ my $user_id = int rand(10);	# FIXME
	
	my $user_id;
	my $name_sha1 = sha1_hex($name);
	my $user_passwd = Conifer->redis->get("user:$name_sha1:passwd");
	if ( $user_passwd and $user_passwd eq md5_base64(sha1_hex($pass)) ) {
		$user_id = Conifer->redis->get("user:$name_sha1:id");
	}
	
	
	return $self->render(message => 'Please Login.') unless $user_id;
	
	my $login_time = &time_and_rand();
	my %user_status = (
		user_id => $user_id,
		login => 1,
		session => "$login_time",
	);
	
	print "LOGIN NAME: $name, STATUS:\n" . Dumper(\%user_status) ."\n";
	
	#~ $memd->set($name => \%user_status) or warn $!;
	
	$self->session(name => "$name", session => "$login_time", user_id => $user_id,);
	$self->flash(message => 'Thanks for logging in!');
	$self->redirect_to('index');
}


sub register {
	# ('name', 'pass', 'email', 'phone')
	# ('realname', 'postal_code', 'country', 'state', 'city', 'district', 'address')
	
	my $self = shift;

	my $user = $self->session('name');
	if ($user) {
		$self->flash(message => 'You are a registered user!');
		$self->redirect_to('index');
	}
	
	my $name = $self->param('name') || '';
	return $self->render(message => 'Please fill your informations here.') unless ($name);
	
	my $pass = $self->param('pass') || '';
	my $email = $self->param('email') || '';
	my $phone = $self->param('phone') || '';
	
	# check if basic columes are valid
	return $self->render(message => 'Not enough information.')
		unless ($pass && $email && $phone);
	
	# FIXME: check in DB
	# check if the user's exist already
	
	#~ my $sth = $dbh->prepare("
		#~ SELECT user_id
		#~ FROM T_user
		#~ WHERE user_code='$name';
	#~ ");
	#~ $sth->execute();
	#~ my $ref = $sth->fetchrow_arrayref;
	#~ my $exists = ${$ref}[0] if $ref;
	#~ $sth->finish();
	
	
	print "User/Redis: ".Dumper(Conifer->redis)."\n";
	
	my $name_sha1 = sha1_hex($name);
	print "name_sha1: $name_sha1\n";
	my $user_id = Conifer->redis->get("user:$name_sha1:id");
	print "Check user_id: $user_id\n";
	
	return $self->render(message => 'User Exist, please choose another username.')
		if $user_id;
	
	#~ $dbh->do("
		#~ insert into T_user
		#~ set	user_code = '$name',
			#~ user_name = '$realname',
			#~ user_passwd = '$pass',
			#~ email = '$email',
			#~ phone_number = '$phone',
			#~ postal_code = '$postal_code',
			#~ country = '$country',
			#~ state = '$state',
			#~ city = '$city',
			#~ district = '$district',
			#~ address = '$address';
	#~ ");
	#~ 
	#~ my $user_id = $dbh->{'mysql_insertid'};
	
	my $user_next_id = Conifer->redis->incr("user:next.id");
	print Dumper(Conifer->redis->incr("user:next.id"))."\n";;
	print "next.id: $user_next_id\n";
	Conifer->redis->setnx("user:$name_sha1:id" => $user_next_id)?
		$user_id = $user_next_id
	:
		$user_id = Conifer->redis->get("user:$name_sha1:id")
	;
	
	Conifer->redis->set( "user:$name_sha1:passwd" => md5_base64(sha1_hex($pass)) );
	# ('realname', 'postal_code', 'country', 'state', 'city', 'district', 'address')
	for (qw[realname postal_code country state city district address]) {
		Conifer->redis->setnx("user:$name_sha1:$_" => $self->param($_)) if $self->param($_);
	}
	
	
	print "USER ID: $user_id\n";
	
	my $login_time = &time_and_rand();
	$self->session(name => "$name", session => "$login_time", user_id => $user_id,);
	$self->flash(message => 'Thanks for Register!');
	$self->redirect_to('index');
	
	#~ $self->render(message => 'Welcome to the Mojolicious Web Framework! ' . $self->stash('id') );
	
}


sub logout {
	# Render template "example/welcome.html.ep" with message
	my $self = shift;
	my $user = $self->session('name');
	
	$self->session(expires => 1);
	
	# FIXME: delete from memcached
	#~ $memd->delete($user);
	
	$self->redirect_to('index');
}


sub info {
	my $self = shift;
	my $user = $self->param('user');
	#~ my $user = $self->session('name');
	#~ $user = &check_user( $user )->{"login"} ? $user : 'Anonymous' ;
	
	#~ my $sth = $dbh->prepare("
		#~ SELECT *
		#~ FROM T_user
		#~ WHERE user_code='$user';
	#~ ");
	#~ $sth->execute();
	#~ my %userinfo = %{$sth->fetchrow_hashref()};
	#~ $sth->finish();	
	my %userinfo;	# FIXME
	
	delete $userinfo{"admin"};
	delete $userinfo{"user_code"};
	delete $userinfo{"register"};
	my $user_id = delete $userinfo{"user_id"};
	
	print Dumper(\%userinfo);
	
	$self->render(message => 'You can edit your informations here.', userinfo => \%userinfo);
	
}


sub edit {
	my $self = shift;
	
	my $user = $self->session('name');
	if (not &check_user( $user )->{"login"}) {
		$self->flash(message => 'Please login first!');
		return $self->redirect_to('login');
	}
	
	# user name canot be changed
	my $pass = $self->param('user_passwd') || '';
	my $email = $self->param('email') || '';
	my $phone = $self->param('phone_number') || '';
	my $realname = $self->param('user_name') || '';
	my $postal_code = $self->param('postal_code') || '';
	my $country = $self->param('country') || '';
	my $state = $self->param('state') || '';
	my $city = $self->param('city') || '';
	my $district = $self->param('district') || '';
	my $address = $self->param('address') || '';
	
	print "$pass, $email, $phone, $realname, $postal_code, $country, $state, $city, $district, $address\n";
	
	# FIXME:
	# get user info from DB.
	# %userinfo = username, password, email, phone
	#~ my $sth = $dbh->prepare("
		#~ SELECT *
		#~ FROM T_user
		#~ WHERE user_code='$user';
	#~ ");
	#~ $sth->execute();
	#~ my %userinfo = %{$sth->fetchrow_hashref()};
	#~ $sth->finish();	
	
	my %userinfo;	# FIXME
	
	delete $userinfo{"admin"};
	delete $userinfo{"user_code"};
	delete $userinfo{"register"};
	my $user_id = delete $userinfo{"user_id"};
	
	print Dumper(\%userinfo);
	
	return $self->render(message => 'You can edit your informations here.', userinfo => \%userinfo) unless ($pass or $email or $phone);
	
	# check if all columes are valid
	return $self->render(message => 'Not enough information. At leaset: password, email, phone number.', userinfo => \%userinfo)
		unless ($pass && $email && $phone);
	
	# FIXME:
	# update new user info to DB
	#~ $dbh->do("
		#~ update T_user
		#~ set	user_name = '$realname',
			#~ user_passwd = '$pass',
			#~ email = '$email',
			#~ phone_number = '$phone',
			#~ postal_code = '$postal_code',
			#~ country = '$country',
			#~ state = '$state',
			#~ city = '$city',
			#~ district = '$district',
			#~ address = '$address'
		#~ where user_id = '$user_id';
	#~ ");
	
	$self->flash(message => 'User Info Updated!');
	$self->redirect_to('index');
	
}



# Functions

sub check_user {
	my ($name, $session_name) = @_;
	my %user_status;
	#~ my $user_status = \%{()};
	my $is_admin;
	# FIXME:
	# 1. check in memcached
	# 2. check DB
	# 3. if ($name == $session_name->{"user"}) { $status = "OK" } else { log_attack };
	# 4. set the user Current status to memcached (if not in memcached)
	# $user = \{"login" => 1, "is_admin" => 0} if $status == "OK";
	# return \%user;
	
	
	#~ my $user_status = $memd->get($name);
	#~ %user_status = %{$user_status} if $user_status;
	
	#~ print "CHECK NAME: $name, STATUS:\n" . Dumper($user_status) ."\n";
	
	#~ if (%user_status) {
		#~ my $sth = $dbh->prepare("
			#~ select admin
			#~ from T_user 
			#~ where user_code = '$name';
		#~ ");
		#~ $sth->execute();
		#~ $is_admin = ${$sth->fetchrow_arrayref}[0];
		#~ $sth->finish();
		#~ 
	#~ }
	
	
	$user_status{"is_admin"} = $is_admin;
	
	#~ print "USER STATUS: \n" . Dumper(\%user_status) . "\n";
	
	return \%user_status;
}

sub time_and_rand {
    
    # Date and time
    my ($sec, $min, $hour, $mday, $month, $year) = localtime;
    $month = $month + 1;
    $year = $year + 1900;
    
    my $microseconds;
    (undef, $microseconds) = gettimeofday;
    
    # Random number(0 ~ 99999)
    #~ my $rand_num = int(rand 100000);
    my $rand_num = int(rand 10);

    # Create file name form datatime and random number
    # (like image-20091014051023-78973)
    #~ my $name = sprintf("%04s%02s%02s%02s%02s%02s.%05s-%05s",
                       #~ $year, $month, $mday, $hour, $min, $sec, $microseconds, $rand_num);
    my $name = sprintf("%04s%02s%02s%02s%02s%02s.%05s-%01s",
                       $year, $month, $mday, $hour, $min, $sec, $microseconds, $rand_num);
    
    return $name;
}

1;
