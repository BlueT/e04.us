package ReFerTo::Pic;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub edit {
	my $self = shift;
	my $user = $self->session('name');
	if (not &check_user( $user )->{"login"}) {
		$self->flash(message => 'Please login first!');
		$self->redirect_to('login');
	}
	
	# FIXME:
	# file delete
	my $delete_list = $self->param('delete_list') || '';
	if ($delete_list) {
		# get filepath and delete the file
		my $sth = $dbh->prepare("
			SELECT file_path 
			FROM T_pic 
			where pic_id = '$delete_list';
		");
		$sth->execute();
		my $ref = $sth->fetchrow_arrayref;
		my $delete_filepath = ${$ref}[0] if $ref;
		$sth->finish();
		
		unlink($delete_filepath);
		# FIXME:
		# show flash msg on the top of the page 
	
		# delete in DB
		$dbh->do("
			delete FROM T_pic
			where pic_id = '$delete_list';
		");
	}
	
	
	# FIXME:
	# Get file id and names from DB
	my %images;
	#~ my @images;
	
	my $sth = $dbh->prepare("
		SELECT pg.pic_group_id,
		       pg.group_name,
		       p.pic_id,
		       p.file_path
		FROM T_pic p,
		     T_picgroup pg,
		     T_user u
		WHERE
		      p.pic_group_id = pg.pic_group_id AND
		      u.user_id = pg.user_id AND
		      u.user_code = '$user';
	");
	$sth->execute();
	
	#~ $VAR1 = {
          #~ 'file_path' => 'image-20100401024709.690235-2.jpg',
          #~ 'group_name' => '2010-04-01',
          #~ 'pic_id' => '6',
          #~ 'pic_group_id' => '4'
        #~ };

	
	while ( my $ref = $sth->fetchrow_hashref() ) {
		#~ print "Found a row: id = $ref->{'id'}, name = $ref->{'name'}\n";
		#~ push @images, $ref;
		my %row_hash = %{$ref} if $ref;
		#~ print Dumper \%row_hash;
		my $group_name = delete $row_hash{"group_name"};
		push @{ $images{$group_name} }, \%row_hash;
	}
	#~ my $ref = $sth->fetchrow_hashref;
	#~ my $user_id = ${$ref}[0] if $ref;
	$sth->finish();		      
	
	print "PIC EDIT:\n".Dumper(\%images)."\n";
	
	# Sort by new order
	#~ my @images_sorted = sort {$b cmp $a} keys %images;
	
	# Render
	#~ return $self->render(images_sorted => \@images_sorted, images => \%images, image_base => $IMAGE_BASE);
	return $self->render(images => \%images, image_base => $IMAGE_BASE);
}

sub upload {
	my $self = shift;
	my $user = $self->session('name');
	if (not &check_user( $user )->{"login"}) {
		$self->flash(message => 'Please login first!');
		$self->redirect_to('login');
	}
	
	# Uploaded image(Mojo::Upload object)
	my $image = $self->req->upload('image');
	
	# Not upload
	unless ($image) {
		return $self->render(
			template => 'upload_error', 
			message  => "Upload fail. File is not specified."
		);
	}
        
	# Over max file size
	if ($image->size > $image_upload_max_fsize) {
		return $self->render(
			template => 'upload_error',
			message  => "Upload fail. Image file size is too large."
		);
	}
    
	# Check file type
	my $image_type = $image->headers->content_type;
	my %valid_types = map {$_ => 1} qw(image/gif image/jpeg image/png);
    
	# Content type is wrong
	unless ($valid_types{$image_type}) {
		return $self->render(
			template => 'upload_error',
			message  => "Upload fail. Content type is wrong."
		);
	}
	
	# Extention
	my $exts = {'image/gif' => 'gif', 'image/jpeg' => 'jpg',
			'image/png' => 'png'};
	my $ext = $exts->{$image_type};
    
	# Image file
	my $image_file_name = "image-" . &time_and_rand(). ".$ext";
	my $image_file = "$IMAGE_DIR/$image_file_name";
	
	# If file is exists, Retry creating filename
	while(-f $image_file){
		$image_file_name = "image-" . &time_and_rand(). ".$ext";
		$image_file = "$IMAGE_DIR/$image_file_name";
	}
    
	# Save to file
	$image->move_to($image_file);
	
	# smaller than min size
	my ($min_height, $min_width) = split/x/,$image_upload_min_size;
	# FIXME: detect image size
	
	my ($image_width, $image_height) = imgsize($image_file);
	if ($image_height < $min_height or $image_width < $min_width) {
		
		# delete file if pic size is too small
		my $del_count = unlink($image_file);
		
		return $self->render(
			template => 'upload_error',
			message  => "Upload fail. Image size is too small. 640x480 at least. Deleted $del_count file(s)."
		);
	}
	
	my $user_id = $memd->get("$user");
	$user_id = $user_id->{"user_id"};
	print "PIC UPLOAD: USER_ID: ".Dumper($user_id)."\n";
	
	# find pic_group
	my $pic_group_id;
	my $sth = $dbh->prepare("
		select pic_group_id
		from T_picgroup
		where	user_id='$user_id' and group_name=current_date();
	");
	$sth->execute();
	my $ref = $sth->fetchrow_arrayref;
	$pic_group_id = ${$ref}[0] if $ref;
	$sth->finish();
	
	# if doesn't exist, create a new one
	if (not $pic_group_id) {
		my $sth = $dbh->do("
			insert into T_picgroup
			set	user_id = '$user_id',
				group_name = current_date(),
				created_time = now();
		");
		$pic_group_id = $dbh->{'mysql_insertid'};
	}
	
	# check pic_size_id
	# $image_height, $image_width
	my $pic_size_id;
	my $sth = $dbh->prepare("
		select pic_size_id
		from T_picsize
		where specification = '$image_width"."x"."$image_height';
	");
	$sth->execute();
	my $ref = $sth->fetchrow_arrayref;
	$pic_size_id = ${$ref}[0] if $ref;
	$sth->finish();
	
	# if doesn't exist, create a new one
	if (not $pic_size_id) {
		my $sth = $dbh->do("
			insert into T_picsize
			set specification = '$image_width"."x"."$image_height';
		");
		$pic_size_id = $dbh->{'mysql_insertid'};
	}
	
	
	# insert pic data into db
	my $sth = $dbh->do("
		insert into T_pic
		set	pic_size_id = '$pic_size_id',
			pic_file_size = '". $image->size ."',
			pic_group_id = '$pic_group_id',
			file_path = '$image_file_name';
	");
	
	# Redirect to top page
	$self->redirect_to('pic_edit');
}
1;
