package Conifer::Fuck;
use utf8;
use Conifer;
use Mojo::Base 'Mojolicious::Controller';
use Time::HiRes 'time', 'gettimeofday';
use Data::Dumper;
#~ use Digest::SHA1 qw(sha1_hex sha1_base64);
#~ use Digest::MD5 qw(md5 md5_hex md5_base64);
use MIME::Base64;

$|=1;

my %hash_table;


sub create {
	my $self = shift;
	my ($who, $whom, $fucks) = ($self->req->param('who'), $self->req->param('whom'), $self->req->param('fucks'));
	
	
	my ($id, $hash) = &_key_gen;
	Conifer->redis->set("fucks:$who:$whom:$id:fucks" => $fucks);
	
	$self->session(who => "$who");
	$self->redirect_to("/$who/fuck/$whom:$hash");
}

sub who_fuck_whom {
	# /(.who)/fuck/(.whom)
	my $self = shift;
	my $who = $self->param('who') || 'anon';
	my ($whom, $hash) = split/:/,$self->param('whom');
	$whom ||= 'anon';
	
	my $id = &_key_lookup($hash);
	
	my $fucks = Conifer->redis->get("fucks:$who:$whom:$id:fucks");
	
	my $motd = "A Fuck A Day, keeps the doctor away.";
	
	$self->render(who => "$who", whom => "$whom", fucks => "$fucks", motd => "$motd");
}

sub comment {
	# comments of fucks
	my $self = shift;
	my $hash = shift;
	my $id = _key_lookup($hash);
	my $list = Conifer->redis->get("comments:$id:list");
}

sub rank {
	# rank/score of fucks/comments
}

sub _key_gen {
	# new id, hash
	my $counter = Conifer->redis->incr('fucks:counter');
	my $hash = encode_base64($counter);
	
	chomp $hash;
	$hash =~ s/=//g;
	
	return($counter, $hash);
}

sub _key_lookup {
	# hash -> id
	my $hash = shift;
	my $id = decode_base64($hash);
	
	return $id;
}

1;
