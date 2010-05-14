# nave

Virtual Environments for Node

## Installation

If you want a global `nave` command, you could install this thing with npm.
But that's not really necessary.  You can run the `nave.sh` shell script
from here, or symlink it wherever you want.

## Usage

    nave install 0.1.92             # install version 0.1.92 of node
    nave test 0.1.92                # run the tests on node version 0.1.92
    nave use 0.1.92                 # enter a subshell where 0.1.92 is being used
    nave use 0.1.92 my-program.js   # run my-program.js with node 0.1.92
    nave ls                         # show the versions fetched/installed
    nave clean 0.1.92               # delete the source code for 0.1.92
    nave uninstall 0.1.92           # delete the install for 0.1.92

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
