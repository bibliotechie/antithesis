package AmuseWikiFarm::Controller::Admin;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

AmuseWikiFarm::Controller::Admin - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched AmuseWikiFarm::Controller::Admin in Admin.');
}

=head2 debug_site_id

Show the site id.

=cut

sub debug_site_id :Local :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body(join(" ",
                            $c->stash->{site_id},
                            $c->stash->{locale},
                           ));
}


=encoding utf8

=head1 AUTHOR

Marco,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
