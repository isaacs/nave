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
      use <ver> <program>  Enter a subshell, and run "node <program>", then exit
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

## env vars

Check the `$NAVE` variable to see which version is being used.  `$NAVELVL` tells
you how many layers in you are.  (A lot of `nave use` commands can create a
nested situation.  Not really sure what this would be useful for, though.)

When you're done using a specific version of node, just exit the shell to return
to where you were before using nave.

## Credits

nave borrows concepts, inspiration, and code from Tim Caswell's "nvm" and Kris
Kowal's "sea" programs.

Sea is really nice, but is very tied to Narwhal.  Also, it's a require.paths
manager, which nave is not.

Nvm is also really nice, but has to be sourced rather than being run, and
thus is a little bit wonky for some use cases.  But it doesn't involve
subshells, which makes it better for many others.
