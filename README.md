# nave

Virtual Environments for Node

## Installation

If you want a global `nave` command, you could install this thing with npm.
But that's not really necessary.  You can run the `nave.sh` shell script
from here, or symlink it wherever you want.

## Usage

    Usage: nave <cmd>

    Commands:

    install <version>    Install the version passed (ex: 0.1.103)
    use <version>        Enter a subshell where <version> is being used
    use <ver> <program>  Enter a subshell, and run "<program>", then exit
    use <name> <ver>     Create a named env, using the specified version.
                         If the name already exists, but the version differs,
                         then it will update the link.
    usemain <version>    Install in /usr/local/bin (ie, use as your main nodejs)
    clean <version>      Delete the source code for <version>
    uninstall <version>  Delete the install for <version>
    ls                   List versions currently installed
    ls-remote            List remote node versions
    ls-all               List remote and local node versions
    latest               Show the most recent dist version
    help                 Output help information

    <version> can be the string "latest" to get the latest distribution.
    <version> can be the string "stable" to get the latest stable version.

That's about it.  Enjoy.

When you're done using a specific version of node, just exit the shell to return
to where you were before using nave.

## env vars

* `$NAVE` The current shell.  Either a version, or a name and version.
* `$NAVENAME` The name of the current shell.  Equal to `$NAVEVERSION` in
  unnammed environments.
* `$NAVEVERSION` The version of node that the current shell is pointing
  to.  (This should comply with `node -v`.)
* `$NAVELVL` The level of nesting in the subshell.
* `$NAVE_DEBUG` Set to 1 to run nave in `bash -x` style.
* `$NAVE_DIR` Set to the location where you'd like nave to do its
  business.  Defaults to `~/.nave`.
* `$NAVE_CONFIG` Set this to an array of arguments to pass to
  `./configure`.  Defaults to `("--debug")`.  (Note that parens are
  required to supply multiple arguments.  I use `("--debug"
  "--without-npm")` on my own system, since I'm usually using nave to
  test npm, so installing it in the subshell doesn't help much.)  This
  can be set in the `~/.naverc` file, or in your normal
  `~/.bash{rc,_profile}` files.
* `$NAVE_JOBS` If set, this will be the number of jobs to run when
  building node.  If this isn't set, it'll use the `$JOBS` env, then try
  to guess a reasonable value based on the number of CPUs, then fall
  back on 2 if `sysctl -n hw.ncpu` fails.

## Compatibility

Prior to version 0.2, nave would run programs as `node <program>`.
However, this is somewhat more limiting, so was dropped.  If you prefer the
old style, just prefix your command with `node`.

Nave requires bash.  It will probably never work on Windows, or other systems
lack a native Bourne Again Shell.  Sorry.

Nave logins work with bash and zsh.  If your shell doesn't set the
`BASH` environment variable, then nave assumes you're using zsh.  As
such, strange archaic shells like sh, csh, tcsh, ksh, and the like will not
work.


## Configuration

Nave will source `~/.naverc` on initialization of a new subshell, if it
exists and is readable.

You may control the place where nave puts things by setting the
`NAVE_DIR` environment variable.  However, note that this must be set
somewhere *other* than `~/.naverc`, since it needs to be set in the
*parent* shell where the `nave` command is invoked.

By default, nave puts its stuff in `~/.nave/`.  If this directory does
not exist and cannot be created, then it will attempt to use the location
of the nave.sh bash script itself.  If it cannot write to this location,
then it will exit with an error.

## Credits

nave borrows concepts, inspiration, and code from Tim Caswell's "nvm" and Kris
Kowal's "sea" programs.

Sea is really nice, but is very tied to Narwhal.  Also, it's a require.paths
manager, which nave is not.

Nvm is also really nice, but has to be sourced rather than being run, and
thus is a little bit wonky for some use cases.  But it doesn't involve
subshells, which makes it better for some others.
