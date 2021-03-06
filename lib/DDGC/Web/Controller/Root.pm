package DDGC::Web::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

__PACKAGE__->config(namespace => '');

sub base :Chained('/') :PathPart('') :CaptureArgs(0) {
    my ( $self, $c ) = @_;

    if ( my ( $username, $password ) = $c->req->headers->authorization_basic ) {
		$c->authenticate({ username => $username, password => $password, }, 'users');
	}

	$c->stash->{template_layout} = [ 'base.tt' ];
	$c->stash->{u} = sub { $c->chained_uri(@_) };
	$c->stash->{l} = sub { $c->localize(@_) };
	$c->stash->{ddgc_config} = $c->d->config;
	$c->stash->{xmpp_userhost} = $c->d->config->prosody_userhost;
	$c->stash->{prefix_title} = 'DuckDuckGo Community';
	$c->stash->{user_counts} = $c->d->user_counts;
    #$c->add_bc('Home', $c->chained_uri('Root','index'));
}

sub index :Chained('base') :PathPart('') :Args(0) {
    my ( $self, $c ) = @_;
#	if ($c->user) {
#		return $c->detach('My','timeline');
#	} else {
	$c->response->redirect($c->chained_uri('Base','welcome'));
	return $c->detach;
#	}
}

sub default :Chained('base') :PathPart('') :Args {
    my ( $self, $c ) = @_;
    $c->response->status(404);
    $c->add_bc('Not found', '');
}

sub end : ActionClass('RenderView') {
    my ( $self, $c ) = @_;
	my $template = $c->action.".tt";
	push @{$c->stash->{template_layout}}, $template;
}

__PACKAGE__->meta->make_immutable;

1;
