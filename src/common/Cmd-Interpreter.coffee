#
# Cmd-Interpreter
#	Handles command line buffers and command execution
#

class CLI
	##
	# @param box The HTML textbox we're taking over
	# @param log The HTML div we're taking over for logging
	constructor: (@box, log) ->
		# Initialize ANSI
		@ansi = new ANSI {
			write: (text) ->
				log.innerHTML += text
				log.scrollTop = log.scrollHeight;
		}

		# Setup path
		#	Entries are [fn, helptext]
		#
		#	See execute() for information about what is
		#	passed to the command function
		@path =
			echo: [@echo, 'Echos whatever you give it!\n\tUsage: echo [-n] message']
			cd: [@cd, 'CD normally changes directory; however, this lesson hasn\'t implemented a filesystem.']

		# Bind key entry
		@box.addEventListener 'keypress', (e) =>
			# Enter?
			if e.which is 13
				@execute()

	##
	# Enables/disables the entry box
	#	This is used mainly by the playback engine
	# @param enabled True to enable, false to disable
	setEnabled: (enabled = true) ->
		@box.disabled = not enabled

	##
	# Returns whether or not manual input is enabled
	enabled: () ->
		not @box.disabled

	##
	# Writes output (with full ANSI support)
	#	to the @log
	write: (message...) ->
		# Join
		message = message.join ' '

		# Render ANSI
		@ansi.render message

	##
	# Executes the current command
	execute: () ->
		# Get value
		value = @box.value
		@box.value = ''
		nl = true

		try
			# Log
			@write "\x1B[30;1m>\x1B[0m #{value}\n"

			# Parse!
			cmd = CLIParser.parse value
			if not cmd
				return @write "\x1B[31;1mSyntax error\x1B[0m\n\n"

			# Do we have a command registered?
			bin = @path[cmd.command]
			if not bin
				return @write "\x1B[31;1mUnknown command: #{cmd.command}\x1B[0m\n\n"

			# Execute!
			#	First arg is the basic command line
			#	Next n args... are the arguments (see below)
			#	
			#	This is passed the `args`
			#	from the parser. This means
			#	every argument is an object,
			#	and every object has, at minimum
			#	a key `key` and may contain a value
			#	with key `val`.
			#
			#	If val is specified, it means the user
			#	specified a key=val on the command line.
			#	Dashes are included
			#	(i.e. --foo=bar -> "--foo", "bar")
			res = bin[0].apply @, [value].concat cmd.args
			if res is true then nl = false
		finally
			@write "\n" if nl

	############################################################
	# BUILT-IN COMMANDS
	############################################################

	##
	# Makes apple pie...
	#
	#	-e is implicit.
	#	Escapes are what are defined in the CLI grammar
	#	-n is really the only option.
	#
	#	Man is a lie.
	echo: (cmd, args...) ->
		# Return if no arguments
		return if not args.length

		# Is the first argument -n?
		newLine = true
		if args[0].key is '-n'
			return if args.length < 2
			newLine = false
			args = args.slice 1

		# Compile arguments
		message = ""
		for arg in args
			if arg.val
				message += " #{arg.key}=#{arg.val}"
			else
				message += " #{arg.key}"

		# Log!
		@write message.substring 1
		@write '\n' if newLine

		# Return true
		#	This is really only pertinent to
		#	echo; it signals to NOT display the
		#	new line.
		#
		#	Useless, really.
		return not newLine

	##
	# Also a lie.
	#
	#	This may be overridden, of course.
	#	Especially by the git lessons.
	cd: () ->
		@write "This lesson hasn't implemented a filesystem!\n"


# Export
if module?
	module.exports = CLI
else
	Codicle.CLI = CLI
