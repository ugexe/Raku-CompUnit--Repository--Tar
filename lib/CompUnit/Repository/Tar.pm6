use Distribution::Common;

class CompUnit::Repository::Tar does CompUnit::Repository {
    has %!loaded;
    has $.prefix;

    method need(CompUnit::DependencySpecification $spec,
                CompUnit::PrecompilationRepository $precomp = self.precomp-repository())
        returns CompUnit:D
    {
        return self.next-repo.need($spec, $precomp) if self.next-repo;
        X::CompUnit::UnsatisfiedDependency.new(:specification($spec)).throw;
    }

    method load(Str(Cool) $spec) returns CompUnit:D {
        state $dist = Distribution::Common::Tar.new($.prefix.IO);
        state %provides-names = $dist.meta<provides>.map({ .key => (.value ~~ Str ?? .value !! .value.key) });
        state %provides-libs  = $dist.meta<provides>.map({ (.value ~~ Str ?? .value !! .value.key) => .key });
        my $name = $spec.split(/^tar\#/)[1] || $spec;

        if (my $name-path = %provides-libs{$name} ?? $name !! %provides-names{$name}) {
            # XXX: Distribution::Common's .slurp-rest(:bin) doesn't work right yet, hence the `.encode`
            my $bytes  = Buf.new( $dist.content($name-path).slurp-rest(:bin)[0].encode );
            my $handle = CompUnit::Loader.load-source( $bytes );
            my $cu = CompUnit.new(
                :$handle,
                :short-name($spec),
                :repo(self),
                :repo-id($spec),
                :precompiled(False),
            );
            return %!loaded{$spec} = $cu;
        }

        return self.next-repo.load($spec) if self.next-repo;
        die("Could not find $spec in:\n" ~ $*REPO.repo-chain.map(*.Str).join("\n").indent(4));
    }

    method loaded() returns Iterable {
        return %!loaded.values;
    }

    method id() {
        'tar'
    }

    method path-spec() {
        'tar#'
    }
}