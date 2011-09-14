package Conifer;
use utf8;
use Mojo::Base 'Mojolicious';
use Data::Dumper;
use Mojo::ByteStream 'b';
use Redis;
#~ use Text::Xslate;
#~ use namespace::clean;

my %redis_server = (server => '127.0.0.1:6379');
my $secret = '';

__PACKAGE__->attr('redis');

__PACKAGE__->redis( Redis->new(%redis_server) );
print Dumper __PACKAGE__->redis;


# This method will run once at server start
sub startup {
	my $self = shift;
	
	
	
	#####
	# Routes
	#####
	
	# Documentation browser under "/perldoc" (this plugin requires Perl 5.10)
	#~ $self->plugin('PODRenderer');
	
	# use Xslate for page rendering
	#~ $self->plugin('xslate_renderer');
	
	$self->secret($secret);

	# Routes
	my $r = $self->routes;
	# $r->route('/:controller/:action/:id')->to('example#welcome', id => 1);
	
	$r->get('/')->to('page#index');
	$r->get('/index')->to('page#index');
	$r->get('/fuck')->to('page#new_fuck');
	$r->route('/echo/(.word)')->to('page#echo');

	# Normal route to controller
	#~ $r->route('/welcome/(.word)')->to('example#welcome');
	
	$r->post('/new/fuck')->to('fuck#create');
	#~ $r->get('/(.who)/fuck(.words)')->to('fuck#who_fuck');
	$r->get('/(.who)/fuck/(.whom)')->to('fuck#who_fuck_whom');
	#~ $r->get('/fuck/(.whom)')->to('fuck#fuck_whom');
	
	
	
}

1;
