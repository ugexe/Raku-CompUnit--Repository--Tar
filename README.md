## CompUnit::Repository::Tar

Load modules directly from a .tar.gz archive

## Synopsis

    use CompUnit::Repository::Tar;
    use lib "CompUnit::Repository::Tar#resources/test-dists/PathTools-v0.2.0.tar.gz";

    require "lib/PathTools.rakumod"  # `require` by relative path
    require "PathTools";             # `require` by name
    use PathTools;                   # `use` by name

See: [tests](https://github.com/ugexe/Raku-CompUnit--Repository--Tar/blob/main/t)
