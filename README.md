# nave

Virtual Environments for Node.

Switch out your node version and global npm install space in one
command.  Supports named environments. Uses subshells by default so
that you can `^D` or `exit` out of an environment quickly.

No need to edit `.bashrc` or `.profile`, just install and go.

## Installation

If you want a global `nave` command, you could install this thing with
npm.  But that's not really necessary.  You can run the `nave.sh`
shell script from here, or symlink it wherever you want.

### with [npm](http://npm.im)

If you have npm, presumably you already have Node, so it's a tiny bit
silly, but maybe you like installing the top-level Node some other
way, and install your subshell version switcher with npm.  Why is a
bash program in npm anyway?  It's fine.  Bits don't judge.

```
npm install -g nave
```

### with [basher](https://github.com/basherpm/basher)

```
basher install isaacs/nave
```

## Usage

To use a version of node, you do this:

```
nave use <some version>
```

If you want to name a virtual env, you can do this:

```
nave use <some name>
```

If that virtual env doesn't already exist, it'll prompt you to choose
a version.

Both of these commands drop you into a subshell.  Exit the shell with
`exit` or `^D` to go back from whence you came.

Here's the full usage statement:

```
Usage: nave <cmd>

Commands:

install <version>     Install the version specified (ex: 12.8.0)
install <name> <ver>  Install the version as a named env
use <version>         Enter a subshell where <version> is being used
use <ver> <program>   Enter a subshell, and run "<program>", then exit
use <name> <ver>      Create a named env, using the specified version.
                      If the name already exists, but the version differs,
                      then it will update the link.
usemain <version>     Install in /usr/local/bin (ie, use as your main nodejs)
clean <version>       Delete the source code for <version>
uninstall <version>   Delete the install for <version>
ls                    List versions currently installed
ls-remote             List remote node versions
ls-all                List remote and local node versions
latest                Show the most recent dist version
cache                 Clear or view the cache
help                  Output help information
auto                  Find a .naverc and then be in that env
auto <dir>            cd into <dir>, then find a .naverc, and be in that env
auto <dir> <cmd>      cd into <dir>, then find a .naverc, and run a command
                      in that env
get <variable>        Print out various nave config values.
exit                  Unset all the NAVE environs (use with 'exec')

Version Strings:
Any command that calls for a version can be provided any of the
following "version-ish" identifies:

- x.y.z       A specific SemVer tuple
- x.y         Major and minor version number
- x           Just a major version number
- lts         The most recent LTS (long-term support) node version
- lts/<name>  The latest in a named LTS set. (argon, boron, etc.)
- lts/*       Same as just "lts"
- latest      The most recent (non-LTS) version
- stable      Backwards-compatible alias for "lts".

To exit a nave subshell, type 'exit' or press ^D.
To run nave *without* a subshell, do 'exec nave use <version>'.
To clear the settings from a nave env, use 'exec nave exit'
```

## Subshell-free operation

If you prefer to not enter a subshell, just run nave with `exec`

```bash
exec nave use lts/argon
```

You could even add something like this to your `.bashrc` file to save
on typing:

```bash
n () {
  exec nave "$@"
}
```

## Running shell script with specific version of Node.js

If there is need to run a shell script with version of node.js provided by nave following snippet can be inserted into script:
```bash
[ "${IN_SUBSHELL}" != "$0" ] && exec env IN_SUBSHELL="$0" nave use 5.0.0 bash "$0" "$@" || :
```

## AUTOMAGICAL!

You can put a `.naverc` file in the root of your project (or
anywhere).  This file should contain the version that you want to use.
It can be something like `lts/boron` or `16` or `latest`

```
echo lts/boron > ~/projects/my-project/.naverc
```

Then you can run `nave auto` to load the appropriate environment.

### BUT THAT'S NOT NEARLY MAGICAL OR AUTO ENOUGH FOR ME THOUGH

If you want to get even more absurd/automated, put this in your bash
settings (like `~/.bashrc` or whatever)

```
alias cd='exec nave auto'
```

and then every time you `cd` into a different folder, it'll
automatically load the correct nave settings, or exit nave-land if no
automatic stuff could be found.

Note that doing this will also cause it to *exit* the nave environment
when you cd to a directory that doesn't have a nave setting, so it can
interfere with "normal" nave operation.

Also, aliasing `cd` is a very all-consuming type of change to make to
one's system.  You might wish to give it some other name, so that you
can switch directories without affecting environment variables as a
potentially surprising side effect, or even just run `exec nave auto`
as an explicit action whenever you want this behavior to happen.

Bottom line, it's your shell, and I hope that this helps you enjoy it
more :)

### NO THAT'S TOO MAGICAL, BE JUST SLIGHTLY LESS MAGICAL THAN THAT

Ok, put this snippet in a `PROMPT_COMMAND` export in your bash
profile (`.bashrc` or `.bash_profile` or whatever you use for
that).

```bash
export PROMPT_COMMAND='nave should-auto && exec nave auto'
```

Now you'll always be in the configured nave environment in any
project with a `.naverc` (or `.nvmrc`), and always _not_ in a
nave environment in your main shell in any folder that isn't
set up for nave auto.

This has no effect on the normal nave subshells you get from
`nave use`.

The output of your `PROMPT_COMMAND` is used for the main bash
prompt, so you can also do some fancy stuff like this:

```bash
__prompt () {
  if nave should-auto; then
    exec nave auto
  if
  # Show the nave version in white-on-blue, but the "normal" node
  # version in green
  if [ "$NAVE" != "" ]; then
    echo -ne " \033[44;37mnode@$NAVE\033[0m"
  else
    echo -ne " \033[32mnode@$(node -p 'process.version.slice(1)' 2>/dev/null)\033[0m"
  fi
}
PS1="\\$ "
export PROMPT_COMMAND='__prompt'
```

## env vars

* `$NAVE` The current shell.  Either a version, or a name and version.
* `$NAVE_NPX` Set to `"1"` to add `node_modules/.bin` to the
  `$PATH` in all nave shells (including the main shell when `exec
  nave auto` is used).
* `$NAVE_AUTO_RC` The `.naverc` file found by `nave auto`.
* `$NAVE_AUTO_CFG` The contents of the `.naverc` file that was
  read when entering the `nave auto` environment.
* `$NAVENAME` The name of the current shell.  Equal to `$NAVEVERSION`
  in unnammed environments.
* `$NAVEVERSION` The version of node that the current shell is
  pointing to.  (This should comply with `node -v`.)
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
  building node.  If this isn't set, it'll use the `$JOBS` env, then
  try to guess a reasonable value based on the number of CPUs, then
  fall back on 2 if `sysctl -n hw.ncpu` fails.
* `$NAVE_SRC_ONLY` Set to `"1"` to only build from source, rather than
  fetching binaries.

## Contributing

Patches welcome!  Before spending too much time on a patch or feature
request, please [post an issue](/isaacs/nave/issues) to see if it's
something that's going to be accepted or have unforeseen consequences.

Patches will usually not be accepted if they break tests or cause coverage
to drop below 100%.  You can run tests with:

```
npm test
# or...
bash test/run.sh
```

And you can check coverage with:

```
npm run cov
# or...
COV=1 bash test/run.sh && open coverage-all/kcov-merged/nave.sh.*.html
```

The latest coverage report can be found at
<https://isaacs.github.io/nave/kcov-merged/index.html>

## Compatibility

Nave is a bash program.  It can still do most of its functionality if you
use zsh or fish as your shell, as long as you have bash _somewhere_, but
some of the magical stuff won't work (since obviously that has to run
inline in your shell with `exec`).

Nave requires bash.  It will probably never work on Windows, or other
systems lack a native Bourne Again Shell.  Sorry.  (Patches welcome if you
can get it to work properly on Windows that _do_ have bash, like WSL and
Cygwin.)

Nave logins work with any shell, but executing a command in the nave
environment (ie, `nave use 12 node program.js`) requires that your shell
support the `-c` argument.  (Bash, sh, zsh, and fish all work fine.)

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

nave borrows concepts, inspiration, and code from Tim Caswell's "nvm"
and Kris Kowal's "sea" programs.

Sea is really nice, but is very tied to Narwhal.  Also, it's a
require.paths manager, which nave is not.

Nvm is also really nice, but has to be sourced rather than being run, and
thus is a little bit wonky for some use cases.  But it doesn't involve
subshells, which makes it better for some others.
