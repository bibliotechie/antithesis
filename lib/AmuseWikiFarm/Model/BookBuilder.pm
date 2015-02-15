package AmuseWikiFarm::Model::BookBuilder;

use strict;
use warnings;
use base 'Catalyst::Model::Factory::PerRequest';

__PACKAGE__->config(
    class => 'AmuseWikiFarm::Archive::BookBuilder',
);

sub prepare_arguments {
    my ($self, $c) = @_;
    my $args = $c->session->{bookbuilder} || {};
    my %constructor = (
        %$args,
        dbic => $c->model('DB'),
       );
    if (my $site = $c->stash->{site}) {
        $constructor{site} = $site;
        $constructor{site_id} = $site->id;
    }
    return \%constructor;
}


=head1 NAME

AmuseWikiFarm::Model::BookBuilder - Bookbuilder helper model

=head1 SYNOPSIS

See L<AmuseWikiFarm>

=head1 DESCRIPTION

Wrap L<AmuseWikiFarm::Archive::BookBuilder> into the catalyst app

=head1 AUTHOR

Marco

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

# Local Variables:
# cperl-indent-parens-as-block: t
# End:
