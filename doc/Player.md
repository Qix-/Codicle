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
    - `present` (`'frame'|'tty'`) - Specifies the type of presentation layer the lesson requires; A **frame** (browser) or
    a **tty** session (console).
    - `tickscript` (`string`) - Holds the entire tickscript
- Init scripts must call `readyCB` (provided by `init` above) when the init script is finished and ready for playback.
- Init scripts that use the **tty** presentation layer must wrap their interpreter/compiler to correctly relay ANSI-compliant
output to/from the TTY panel.

## TickScripts (wrapper)

TickScript is Codicle's basic scripting format that governs how the lesson is to playback to the user.

TickScript is designed to be **minimal in size** but expandable by the browser -- that's to say, it imposes
more processing on the client-side than the server side.

TickScript is built to specify metadata, the single audio file to load, the chapters, the time offsets for each chapter,
and the characters typed for both the presentation pane and the coding pane - including a few other pieces of information.

Upon pausing or at chapter breaks (if the user has specified they want to pause after each chapter), the user can enter
code and play with what the instructor has typed in the editor. When the user resumes playback, the code *before* the pause
is restored and the lesson continues.

> This was a somewhat difficult call to make; other sites doing similar things don't actually check for user interaction while
the code is being played back, causing lots of errors and making the playback engine lose track. This enforces the code
works every time.

### Specification
The JSON format for a tickscript file is as follows:

```
{
	"version": <string> tick spec version ('v1', etc.)
	"name": <string> lesson name
	"author": <string> author name
	"audio": <url> the audio clip to use (omit extension; must have WAV and OGG formats)
	"bgm": <url> the background music to play while playback is occuring. See note.
	"chapters": {
		"name": <int> # of seconds within the audio file this chapter starts at
		...
		}
	"ticks": <string> tickscript (see specification below)
}
```

> Background music is more of a UX thing - audio is paused when commands are run due to the fact
> users' browsers might (will) take longer than the instructor's (or even the other way around).
> The `~` marker below signals the playback to freeze momentarily until the REPL is back to an idle
> state -- however, the background music will still play (unlike when the playback is actually paused).
>
> This eliminates awkward silence and doesn't shame the user if they have an unbearably slow computer,
> ultimately giving the illusion of a seamless playback experience.
>
> The goal of background music is to make the playback more like a video and less like a soundbit.
> Users *do* have the option of disabling background music as well.

# TickScript v1

TickScript instructions are made up of various directives and ultimately form a single, long string.

TickScript operates off of time relative to an audio file instead of chronologic or sequential application.
This is to ensure synchronization with the instructor's voice, and means tickscript is seekable; the client
will be able to construct a complete timeline of events if the user seeks through the lesson no matter where.

Tickscript instructions are made up of **markers** that specify time relative to the last marker. The format of
a marker is `[D...][L...]S[A...]`:
- `\s` _(space)_ denotes a marker that uses the same timestamp as the last marker
- `D...`, if specified, denotes one or more digits that make up the **integer** portion of the seconds count
- `L...`, if specified, denotes one or more **letter-mapped-digits** (A=0, B=1, ... J=9) that make up the **decimal** portion of the seconds count

> If neither of the `D...` or `L...` blocks are specified, the marker is performed at the same time as the last marker.

- `S` denotes a command. `S` must not be an alphanumeric character or `.` or whitespace
- `A...` specifies one or more argument characters. These must either be a **constant length** or have a **terminator** (each command is different).
Some commands to not accept arguments and thus the `A...` clause is omitted.

Tickscript ignores newlines and thus have their own newline command.

### Specification

Limitations:
- Highlighting is NOT supported. TickScript creators should be conscious of this and use backspaces.

A list of modifiers:
- `:C` - types character `C` (not including newlines; always treated literally)
- `^D` - simulates an arrow press in the given `D` direction (one of `UDLR`)
- `*N;` - repeats the last command `N` times (terminated)
- `#` - simulates the *enter* key
- `/` - simulates the *delete* key
- `<` - simulates the *backspace* character
- `-` - simulates the *tab* character
- `%X` - jumps to the end of a line (X=`h` for home, X=`e` for end)
- `$X` - jumps to the next word (ctrl+click) (X=`l` for left, X=`r` for right)
- `@R,C;` - jumps cursor to row `R` and col `C` (terminated)
- `>X` - switches simulated keystrokes to the given frame (X=`p` for presentation frame, X=`e` for editor)
- `!` - force-pauses the playback
- `~` - waits for a console command to return (see note above about background music)

#### (Short) Example
```
>e
@0,0;
3F:HB:eB:lB:lB:oB:,B: B:wB:oB:rB:lB:dB:!B: B::B:)
*2;
1B<B<
1#
!
```
- Focuses the editor
- Moves cursor to origin (0,0)
- Waits 3.5 seconds and begins typing "Hello, world! :)", pressing a key every 0.2 seconds
- Types '))' instantly
- Waits 1 second, backspaces twice; once every 0.2 seconds
- Waits 1 second and hits the enter key
- Force-pauses

The above example can be condensed down to a single string:
`>e@0,0;3F:HB:eB:lB:lB:oB:,B: B:wB:oB:rB:lB:dB:!B: B::B:)*2;1B<B<1#!`