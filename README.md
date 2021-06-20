## CompUnit::Repository::Tar

Load modules directly from a .tar.gz archive

# Synopsis

    use CompUnit::Repository::Tar;
    use lib "CompUnit::Repository::Tar#resources/test-dists/zef.tar.gz";

    require "lib/Zef.pm6"  # `require` by relative path
    require "Zef";         # `require` by name
    use Zef;               # `use` by name

See: [tests](https://github.com/ugexe/CompUnit--Repository--Tar/blob/master/t)
