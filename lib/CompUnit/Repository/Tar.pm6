use Distribution::Common;
use nqp;

class CompUnit::Repository::Tar does CompUnit::Repository {
    has %!loaded;
    has $.prefix;

    my %seen;

    method !dist      { state $dist = Distribution::Common::Tar.new($.prefix.IO) }
    method !path2name { state %path2name = self!dist.meta<provides>.map({ (.value ~~ Str ?? .value !! .value.key) => .key }) }
    method !name2path { state %name2path = self!dist.meta<provides>.map({ .key => (.value ~~ Str ?? .value !! .value.key) }) }

    method need(CompUnit::DependencySpecification $spec,
                CompUnit::PrecompilationRepository $precomp = self.precomp-repository())
        returns CompUnit:D
    {
        my $name      = $spec.short-name;
        my $name-path = self!name2path{$name};

        if $name-path {
            my $base = $!prefix.IO.child($name-path);
            return %!loaded{$name} if %!loaded{$name}:exists;
            return %seen{$base}    if %seen{$base}:exists;

            my $id = nqp::sha1($name ~ $*REPO.id);
            my $*RESOURCES = Distribution::Resources.new(:repo(self), :dist-id(''));

            my $bytes  = Blob.new( self!dist.content($name-path).slurp-rest(:bin) );
            my $handle = CompUnit::Loader.load-source( $bytes );

            return %!loaded{$name} //= %seen{$base} = CompUnit.new(
                :short-name($name),
                :$handle,
                :repo(self),
                :repo-id($id),
                :!precompiled,
            );
        }

        return self.next-repo.need($spec, $precomp) if self.next-repo;
        X::CompUnit::UnsatisfiedDependency.new(:specification($spec)).throw;
    }

    method load(Str(Cool) $name-path) returns CompUnit:D {
        my $name = self!path2name{$name-path} // (self!name2path{$name-path} ?? $name-path !! Nil);
        my $path = self!name2path{$name-path} // (self!path2name{$name-path} ?? $name-path !! Nil);

        if $path {
            # XXX: Distribution::Common's .slurp-rest(:bin) doesn't work right yet, hence the `.encode`
            my $bytes  = Blob.new( self!dist.content($path).slurp-rest(:bin) );
            my $handle = CompUnit::Loader.load-source( $bytes );
            my $base   = ~$!prefix.IO.child($path);
            return %!loaded{$path} //= %seen{$base} = CompUnit.new(
                :$handle,
                :short-name($path),
                :repo(self),
                :repo-id(~$!prefix),
                :!precompiled,
            );
        }

        return self.next-repo.load($path) if self.next-repo;
        die("Could not find $path in:\n" ~ $*REPO.repo-chain.map(*.Str).join("\n").indent(4));
    }

    method loaded() returns Iterable {
        return %!loaded.values;
    }

    method id() {
        'tar'
    }

    method short-id() {
        'tar'
    }

    method path-spec() {
        'tar#'
    }
}