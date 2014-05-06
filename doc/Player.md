# Codicle Player

The **Codicle Player** sets up an environment specialized not only for a specific lesson,
but for a specific language as well.

The codicle player must be supplied with a function exported from an **init script** (see below)
that is called in order to set up the player for the particular lesson.

> The initscript framework is open-source, but individual Codicle lessons and initscripts are not.

The init script specifies what kind of *presentation* pane it requires (i.e. browser, console, etc.), and
in the case of console-based lessons the init script must invoke a
[REPL](http://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop),
which then harnesses the player's stream-like handles (which include full ANSI support) for I/O
operations.

> The full-ANSI support is included due to the fact some environments have actually be compiled
> from their native sources, which do include colors. At the time of this writing, ANSI support
> is quite rough and definitely could use some [help](https://github.com/Codicle/bash.js).

From there, the initscript will then preload the lesson. This includes things like audio clips,
the **TickScript** file(s), initial code, and optionally run initial commands in the REPL window.

## InitScripts

Init scripts are scripts that run when the player loads and latch onto the player's
built-in facilities, ultimately setting up the environment.

As mentioned earlier, init scripts specify the type of presentation pane (browser or console)
and then continue to configure that pane.

For instance, browser panes can be reset and console panes can be initialized (ideally with a REPL)
using the provided stdin/out/err 'streams'.

From there, init scripts tell the player which assets it would like to preload for the lesson,
continue to setup initial code snippets or run initial REPL commands.

Once all assets have been pre-loaded and the initscript has signalled it's done all of its configuration
then the player starts up.

### Specification

- Init scripts are *always loaded after the environment*. The environment is considered dormant until an init
script has activated it.
- An init script is responsible for calling `codiclePlayerInit({})`, supplying an object with the following
properties:
    - `init` (`function(readyCB)`) - Called when the initscript should run. **Do not run initialization steps outside of this
    function!**
    - `preload` (`{string:url,...}`) - A map of ID=>URL pairs that denote preloadable assets. These assets are retrieved
    concurrently by the player and are stored in-place of the URLs. These are usually sounds or other larger objects.
    - `load` (`function(id)`) - Called when an asset is loaded; function is passed the ID specified in `preload`.
    - `present` (`'frame'|'tty'`) - Specifies the type of presentation layer the lesson requires; A **frame** (browser) or
    a **tty** session (console).
- Init scripts must call `readyCB` (provided by `init` above) when the init script is finished and ready for playback.
- Init scripts that use the **tty** presentation layer must wrap their interpreter/compiler to correctly relay ANSI-compliant
output to/from the TTY panel.