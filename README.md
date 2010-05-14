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
    nave my-program.js              # run my-program.js with the active node

That's about it.  Enjoy.

## env vars

Check the `$NAVE` variable to see which version is being used.  `$NAVELVL` tells
you how many layers in you are.  (A lot of `nave use` commands can create a
nested situation.  Not really sure what this would be useful for, though.)
