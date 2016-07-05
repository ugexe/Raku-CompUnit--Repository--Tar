use Test;
plan 4;

use CompUnit::Repository::Tar;
$*REPO; # init repo chain so AbsolutePath and NQP repos are available during precomp
PROCESS::<$REPO> := CompUnit::Repository::Tar.new(
    :prefix($?FILE.IO.parent.child('data/zef.tar.gz')),
    :next-repo(CompUnit::RepositoryRegistry.repository-for-name('perl')),
    :name('tar'),
);

ok '$!dist' !~~ any( ::("Candidate").^attributes>>.name );
lives-ok { require "tar#lib/Zef.pm6" };
ok '$!dist' ~~ any( ::("Candidate").^attributes>>.name );

lives-ok { require "tar#lib/Zef/Client.pm6" } # Could not find Zef at line 1