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

## Troubleshooting

If nave doesn't seem to update the version of node that you're using,
make sure you're not explicitly setting the `PATH` environ in your
.bashrc or .bash_profile files.  Nave works by setting the PATH, so you
should change any line like this:

    export PATH=/blah/blah:/foo/foo

to something like this instead:

    export PATH=$PATH:/blah/blah:/foo/foo

## Compatibility

Prior to version 0.2, nave would run programs as `node <program>`.
However, this is somewhat more limiting, so was dropped.

If you prefer the old style, just prefix your command with `node`.

## Credits

nave borrows concepts, inspiration, and code from Tim Caswell's "nvm" and Kris
Kowal's "sea" programs.

Sea is really nice, but is very tied to Narwhal.  Also, it's a require.paths
manager, which nave is not.

Nvm is also really nice, but has to be sourced rather than being run, and
thus is a little bit wonky for some use cases.  But it doesn't involve
subshells, which makes it better for some others.
