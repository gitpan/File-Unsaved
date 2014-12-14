package File::Unsaved;

our $DATE = '2014-12-14'; # DATE
our $VERSION = '0.03'; # VERSION

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
opened and has unsaved modification in an editor. Currently the supported
editors are: Emacs, joe, vim.

Return false if no unsaved data is detected, or else a hash structure. Hash will
contain these keys: `editor` (kind of editor).

The heuristics are as folow:

* Emacs and joe: check whether `.#<name>` symlink exists. Emacs targets the
  symlink to `<user>@<host>.<PID>:<timestamp>` while joe to
  `<user>@<host>.<PID>`. Caveat: Unix only.

* vim: check whether `.<name>.swp` file exists, not older than file, and its
  0x03ef-th byte has the value of `U` (which vim uses to mark the file as
  unsaved). Caveat: vim can be instructed to put swap file somewhere else or not
  create swap file at all, so in those cases unsaved data will not be detected.

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

    my ($vol, $dir, $file) = File::Spec->splitpath($path);

    # emacs & joe
    {
        my $spath = File::Spec->catpath($vol, $dir, ".#$file");
        last unless -l $spath;
        my $target = readlink $spath;
        if ($target =~ /:\d+$/) {
            return {editor=>'emacs'};
        } else {
            return {editor=>'joe'};
        }
    }

    # vim
    {
        my $spath = File::Spec->catpath($vol, $dir, ".$file.swp");
        last unless -f $spath;
        last if (-M $spath) > (-M $path); # swap file is older
        open my($fh), "<", $spath or last;
        sysseek $fh, 0x03ef, 0 or last;
        sysread $fh, my($data), 1 or last;
        $data eq 'U' or last;
        return {editor => 'vim'};
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

This document describes version 0.03 of File::Unsaved (from Perl distribution File-Unsaved), released on 2014-12-14.

=head1 SYNOPSIS

 use File::Unsaved qw(check_unsaved_file);
 die "Can't modify foo.txt because it is being opened and modified in an editor"
     if check_unsaved_file(path => "foo.txt");

=head1 DESCRIPTION

=head1 FUNCTIONS


=head2 check_unsaved_file(%args) -> any

Check whether file has unsaved modification in an editor.

This function tries, using some heuristics, to find out if a file is being
opened and has unsaved modification in an editor. Currently the supported
editors are: Emacs, joe, vim.

Return false if no unsaved data is detected, or else a hash structure. Hash will
contain these keys: C<editor> (kind of editor).

The heuristics are as folow:

=over

=item * Emacs and joe: check whether C<< .#E<lt>nameE<gt> >> symlink exists. Emacs targets the
symlink to C<< E<lt>userE<gt>@E<lt>hostE<gt>.E<lt>PIDE<gt>:E<lt>timestampE<gt> >> while joe to
C<< E<lt>userE<gt>@E<lt>hostE<gt>.E<lt>PIDE<gt> >>. Caveat: Unix only.

=item * vim: check whether C<< .E<lt>nameE<gt>.swp >> file exists, not older than file, and its
0x03ef-th byte has the value of C<U> (which vim uses to mark the file as
unsaved). Caveat: vim can be instructed to put swap file somewhere else or not
create swap file at all, so in those cases unsaved data will not be detected.

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
