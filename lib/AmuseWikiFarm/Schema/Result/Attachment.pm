use utf8;
package AmuseWikiFarm::Schema::Result::Attachment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

AmuseWikiFarm::Schema::Result::Attachment - Attachment to texts

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<attachment>

=cut

__PACKAGE__->table("attachment");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 f_path

  data_type: 'text'
  is_nullable: 0

=head2 f_name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 f_archive_rel_path

  data_type: 'varchar'
  is_nullable: 0
  size: 32

=head2 f_timestamp

  data_type: 'datetime'
  is_nullable: 0

=head2 f_timestamp_epoch

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 f_full_path_name

  data_type: 'text'
  is_nullable: 0

=head2 f_suffix

  data_type: 'varchar'
  is_nullable: 0
  size: 16

=head2 f_class

  data_type: 'varchar'
  is_nullable: 0
  size: 16

=head2 uri

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 title_muse

  data_type: 'text'
  is_nullable: 1

=head2 comment_muse

  data_type: 'text'
  is_nullable: 1

=head2 title_html

  data_type: 'text'
  is_nullable: 1

=head2 comment_html

  data_type: 'text'
  is_nullable: 1

=head2 site_id

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 16

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "f_path",
  { data_type => "text", is_nullable => 0 },
  "f_name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "f_archive_rel_path",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "f_timestamp",
  { data_type => "datetime", is_nullable => 0 },
  "f_timestamp_epoch",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "f_full_path_name",
  { data_type => "text", is_nullable => 0 },
  "f_suffix",
  { data_type => "varchar", is_nullable => 0, size => 16 },
  "f_class",
  { data_type => "varchar", is_nullable => 0, size => 16 },
  "uri",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "title_muse",
  { data_type => "text", is_nullable => 1 },
  "comment_muse",
  { data_type => "text", is_nullable => 1 },
  "title_html",
  { data_type => "text", is_nullable => 1 },
  "comment_html",
  { data_type => "text", is_nullable => 1 },
  "site_id",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 16 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<uri_site_id_unique>

=over 4

=item * L</uri>

=item * L</site_id>

=back

=cut

__PACKAGE__->add_unique_constraint("uri_site_id_unique", ["uri", "site_id"]);

=head1 RELATIONS

=head2 global_site_files

Type: has_many

Related object: L<AmuseWikiFarm::Schema::Result::GlobalSiteFile>

=cut

__PACKAGE__->has_many(
  "global_site_files",
  "AmuseWikiFarm::Schema::Result::GlobalSiteFile",
  { "foreign.attachment_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 site

Type: belongs_to

Related object: L<AmuseWikiFarm::Schema::Result::Site>

=cut

__PACKAGE__->belongs_to(
  "site",
  "AmuseWikiFarm::Schema::Result::Site",
  { id => "site_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2017-10-29 09:46:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Mw+7E+47hobdPiK7t4XC/A

=head2 File classes

Defined C<f_class> values:

=over 4

=item image

A standard image

=item special_image

An images beloging to a special text

=item upload_pdf

A pdf. Cannot be inlined.

=back

=head3 can_be_inlined

Return false if it's a PDF, false otherwise

=cut

use Text::Amuse::Functions qw/muse_format_line muse_to_html/;
use AmuseWikiFarm::Log::Contextual;

sub can_be_inlined {
    my $self = shift;
    if ($self->f_class eq 'upload_pdf') {
        return 0;
    }
    else {
        return 1;
    }
}

sub full_uri {
    my $self = shift;
    my %type = (
                image => sub { '/library/' . $self->uri },
                special_image => sub { '/special/' . $self->uri },
                upload_pdf => sub { '/uploads/' . $self->site->id . '/' . $self->uri },
               );
    if (my $sub = $type{$self->f_class}) {
        return $sub->();
    }
    else {
        log_error { $self->f_class . ' for ' . $self->f_full_path_name . ' is not recognized' };
    }
    return undef;
}

sub thumbnail_base_path {
    my $self = shift;
    return '/uploads/' . $self->site->id . '/thumbnails/' . $self->uri;
}

sub thumbnail_uri {
    return shift->thumbnail_base_path . '.thumb.png';
}

sub small_uri {
    return shift->thumbnail_base_path . '.small.png';
}

sub large_uri {
    return shift->thumbnail_base_path . '.large.png';
}

sub edit {
    my ($self, %args) = @_;
    my %update;
    foreach my $k (qw/title_muse comment_muse/) {
        $update{$k} = defined($args{$k}) ? $args{$k} : '';
    }
    $update{title_html} = muse_format_line(html => $update{title_muse});
    $update{comment_html} = muse_to_html($update{comment_muse});
    Dlog_debug { "Updating $_" } \%update;
    $self->update(\%update);
}

sub separator { return undef }



__PACKAGE__->meta->make_immutable;
1;
