#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;

my %OPT;
GetOptions( \%OPT, 'revision|r=s@', 'top|t', 'debug|d', 'horizontal|o',
	'help|h' );

print STDERR Dumper %OPT if ( $OPT{debug} );

&help() if ( $OPT{help} );

my $VIMDIFFOPT = '-R';    # read only
$VIMDIFFOPT .= ' -o' if ( $OPT{horizontal} );
$VIMDIFFOPT .= ' +"syn off"';    # syntax off

my $VIMDIFF = "vimdiff $VIMDIFFOPT";

my $prev_rev = "";
if ( $OPT{top} && $OPT{revision} ) {
	if ( @{ $OPT{revision} } != 1 ) {
		print "--top指定時は、--revisionの複数指定はできません\n";
		exit 0;
	}

	my $prev_rev = &getPrevRev( $OPT{revision}[0] );
	unshift @{ $OPT{revision} }, $prev_rev;
	print "\$prev_rev : $prev_rev\n" if ( $OPT{debug} );
}

my $top_with_no_rev_flg = 0;
if ( $OPT{top} && !$OPT{revision} ) {
	$top_with_no_rev_flg++;
}

if(@ARGV == 0) {
	my @update_list = `svn stat | grep -E '^[UP] ' | perl -lane 'print \$F[1]'`;
	chomp @update_list;
	@ARGV = @update_list;
}
for my $arg (@ARGV) {
	if ($top_with_no_rev_flg) {
#		undef $OPT{revision};
#		my $latest_rev = &getLatestRev($arg);
#		die "svn stat error!" unless $latest_rev;
#		my $prev_rev = &getPrevRev($latest_rev);
#		push @{ $OPT{revision} }, $prev_rev;
#		push @{ $OPT{revision} }, $latest_rev;
	}

	print STDERR Dumper %OPT if ( $OPT{debug} );

	( my $flat_path = $arg ) =~ s!/!@!g;
	my $latest_path_base = '/tmp/svn' . $$ . '@' . $flat_path;

	if ( $OPT{revision} || $OPT{top} ) {
		my @latest_list   = ();
		my $latest_path_r = "";
		for my $opt_r ( @{ $OPT{revision} } ) {
			print "\$OPT{revision} specified : $opt_r\n" if ( $OPT{debug} );
			$latest_path_r = $latest_path_base . '@' . $opt_r . ".tmp";
			print "$latest_path_r\n" if ( $OPT{debug} );
			push @latest_list, $latest_path_r;
			system("svn cat -r $opt_r $arg > $latest_path_r");
		}

		if ( @{ $OPT{revision} } == 1 ) {
			system("$VIMDIFF $arg $latest_path_r");
		}
		else {
			system("$VIMDIFF @latest_list");
		}
		unlink @latest_list if (@latest_list);
	}
	else {
		my $latest_path = $latest_path_base . ".tmp";
		system("svn cat $arg > $latest_path");
		system("$VIMDIFF $arg $latest_path") unless ( $OPT{debug} );
		unlink $latest_path;
	}
}

sub getPrevRev {
	my $cur_rev = shift;
	( my $cur_rev_bottom = $cur_rev ) =~ s/(.*\.)(\d+)$/$2/;
	my $cur_rev_top = $1;
	$cur_rev_bottom-- if ( $cur_rev_bottom > 1 );
	$prev_rev = $cur_rev_top . $cur_rev_bottom;
	return $prev_rev;
}

#sub getLatestRev {
#	my $file     = shift;
#	my @cvs_stat = `cvs stat -v $file`;
#	my @res      = grep /Repository revision:/, @cvs_stat;
#	chomp(@res);
#	( my $rev = $res[0] ) =~ s/\s+Repository revision:\s+([\d\.]+)\s+.*/$1/;
#	print "\$rev : $rev\n" if ( $OPT{debug} );
#	return $rev;
#}

sub help {
	use File::Basename;
	my $cmd = basename($0);
	print <<EOD;
NAME:
  $cmd - vimdiffによるSVN差分表示ツール
SYNOPSIS:
  $cmd [options] [file1 file2 file3]
DESCRIPTION:
  指定したファイルとSVNの最新リビジョンとのvimdiffをとる

  --revision,-r リビジョン
    SVNのリビジョンを指定
    -r rev1 -r rev2 などと複数指定可能(左から指定順に評価)
  --top,-t
    直前のリビジョンとの差分をとる(cvs rdiff -tと同様のイメージ)
      --revision指定時は、そのリビジョンとその直前との差分
      --revision指定なし時は、最新リビジョンと直前との差分
      ※直前とはリビジョン番号の最小桁の数字を-1したもの
  --horizontal,-o
    vimdiffの差分をhorizontal splitモードで見る
  --help,-h
    ヘルプを表示
EOD
	exit 0;
}

