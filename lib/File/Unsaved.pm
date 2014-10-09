package File::Unsaved;

our $DATE = '2014-10-09'; # DATE
our $VERSION = '0.01'; # VERSION

use 5.010001;
use strict;
use warnings;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(check_unsaved_file);

our %SPEC;

$SPEC{check_unsaved_file} = {
    v => 1.1,
    summary => 'Check whether file has unsaved modification in an editor',
    description => <<'_',

This function tries, using some heuristics, to find out if a file is being
opened and has unsaved modification in an editor. Currently the supported editor
is Emacs.

Return false if no unsaved data is detected, or else a hash structure. Hash will
contain these keys: `editor` (kind of editor).

The heuristics are as folow:

* Emacs: check whether `.#<name>` (symlink) exists.

_
    args => {
        path => {
            schema => 'str*',
            req => 1,
            pos => 0,
        },
    },
    result_naked => 1,
};
sub check_unsaved_file{
    require File::Spec;

    my %args = @_;

    my $path = $args{path};
    (-f $path) or die "File does not exist or not a regular file";

    # emacs
    {
        my ($vol, $dir, $file) = File::Spec->splitpath($path);
        my $spath = File::Spec->catpath($vol, $dir, ".#$file");
        if (-l $spath) {
            return {editor=>'emacs'};
        }
    }

    undef;
}

1;
# ABSTRACT: Check whether file has unsaved modification in an editor

__END__

=pod

=encoding UTF-8

=head1 NAME

File::Unsaved - Check whether file has unsaved modification in an editor

=head1 VERSION

This document describes version 0.01 of File::Unsaved (from Perl distribution File-Unsaved), released on 2014-10-09.

=head1 SYNOPSIS

 use File::Unsaved qw(check_file_unsaved);
 die "Can't modify foo.txt because it is being opened and modified in an editor"
     if check_file_unsaved(path => "foo.txt");

=head1 DESCRIPTION

=head1 FUNCTIONS


=head2 check_unsaved_file(%args) -> any

Check whether file has unsaved modification in an editor.

This function tries, using some heuristics, to find out if a file is being
opened and has unsaved modification in an editor. Currently the supported editor
is Emacs.

Return false if no unsaved data is detected, or else a hash structure. Hash will
contain these keys: C<editor> (kind of editor).

The heuristics are as folow:

=over

=item * Emacs: check whether C<< .#E<lt>nameE<gt> >> (symlink) exists.

=back

Arguments ('*' denotes required arguments):

=over 4

=item * B<path>* => I<str>

=back

Return value:

 (any)

=head1 SEE ALSO

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/File-Unsaved>.

=head1 SOURCE

Source repository is at L<https://github.com/perlancar/perl-File-Unsaved>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=File-Unsaved>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

perlancar <perlancar@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by perlancar@cpan.org.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
