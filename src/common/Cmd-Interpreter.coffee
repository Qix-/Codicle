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

		# Setup history
		#	currentLine is so if we type something,
		#	hit up, and then back down, what we were
		#	typing persists. This is common functionality
		#	with a lot of CLI's.
		@history = []
		@currentLine = ""
		@historyIndex = -1

		# Setup buffer caret position
		#	This is used when the box is being
		#	automated
		@caretPosition = 0

		# Setup path
		#	Entries are [fn, helptext]
		#
		#	See execute() for information about what is
		#	passed to the command function
		@path =
			echo: [@echo, 'Echos whatever you give it!\n\tUsage: echo [-n] message']
			cd: [@cd, 'CD normally changes directory; however, this lesson hasn\'t implemented a filesystem.']
			man: [@man, 'Displays help for a particular command (i.e. man echo)']

		# Bind key press
		@box.addEventListener 'keypress', (e) =>
			# Enter?
			@execute() if e.which is 13
		
		# Bind key down
		@box.addEventListener 'keydown', (e) =>
			# Switch
			switch e.keyCode
				# Tab
				when 9
					e.preventDefault()
					@autoComplete()
					@box.focus()
					return false

				# Up/Down
				when 38 then @lastCommand()
				when 40 then @nextCommand()

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

	type: (chr) ->
		if @caretPosition is @box.value.length
			@box.value += chr
		else
			@box.value = @box.value.substring(0, @caretPosition) + chr +
				@box.value.substring(@caretPosition)
		@caretPosition += chr.length

	##
	# Restores a command recently executed
	# 	from higher in the list
	lastCommand: () ->
		# Check for beginning
		return if @historyIndex is 0

		# Have they been typing a command?
		if @historyIndex is -1
			return if @history.length is 0
			@currentLine = @box.value
			@historyIndex = @history.length

		# Restore history
		--@historyIndex
		@box.value = @history[@historyIndex]

		# Reset caret position
		@caretPosition = @box.value.length

	##
	# Restores a command recently executed
	# 	from lower in the list
	nextCommand: () ->
		# Check for end
		return if @historyIndex is -1

		# Increment and check
		++@historyIndex
		if @historyIndex is @history.length
			# Restore and set
			@box.value = @currentLine
			@historyIndex = -1
		else
			# Restore
			@box.value = @history[@historyIndex]

		# Reset caret position
		@caretPosition = @box.value.length

	##
	# Moves the internal caret position left
	left: () ->
		--@caretPosition if @caretPosition > 0

	##
	# Moves the internal caret position right
	right: () ->
		++@caretPosition if @caretPosition < @box.value.length

	##
	# Deletes a character at the caret position
	del: () ->
		return if @caretPosition is @box.value.length
		if @caretPosition is @box.value.length - 1
			@box.value = @box.value.substring 0, @box.value.length - 1
		else if @caretPosition > 0
			@box.value = @box.value.substring(0, @caretPosition) + @box.value.substring(@caretPosition + 1)
		else
			@box.value = @box.value.substring 1

	##
	# Backspaces a character at the caret position
	backspace: () ->
		return if @caretPosition is 0
		if @caretPosition is 1
			@box.value = @box.value.substring 1
		else if @caretPosition is @box.value.length
			@box.value = @box.value.substring 0, @box.value.length - 1
		else
			@box.value = @box.value.substring(0, @caretPosition - 1) + @box.value.substring @caretPosition
		--@caretPosition

	##
	# Sets the absolute column
	# @param column The column to jump to
	col: (column) ->
		@caretPosition = column

	##
	# Attempts to auto-complete what the user has
	#	typed in.
	autoComplete: () ->
		# Get our value
		value = @box.value

		# Are we still typing a command?
		#	Yes, autocomplete only works with
		#	non-quoted commands.
		return if value.match /^\s*[^\s]+\s+/
		value = value.replace /^\s*/, ''

		# Empty value?
		if value.length is 0
			@write "#{Object.keys(@path).join '\n'}\n\n"
			return @write "\n\n"

		# Setup matches
		matches = []

		# Iterate path
		for entry of @path
			# Does it match?
			matches.push entry if entry.indexOf(value) is 0

		# Any? :(
		return if matches.length is 0

		# Append and continue
		if matches.length is 1
			@box.value += matches[0].substring value.length
			@box.value += ' '

			# Reset buffer caret position
			@caretPosition = @box.value.length
			return

		# Display possibilities
		return @write "#{matches.join '\n'}\n\n"


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
		# Empty?
		return if not @box.value.length

		# Get value
		value = @box.value
		@box.value = ''
		nl = true

		# Reset buffer caret position
		@caretPosition = 0

		# Reset history index
		@historyIndex = -1
		@currentLine = ''

		try
			# Log
			@write "\x1B[30;1m>\x1B[37m #{value}\x1B[0m\n"

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

			# Add to history
			@history.push value
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

	##
	# Displays help about a command
	#
	#	Man is a TOTAL lie by now...
	# @param command The name of the command to lookup
	man: (c, command) ->
		# Command?
		if not command
			@write @path['man'][1], '\n'
			return @write "error: no command given\n"

		# Do we have the command?
		cmd = @path[command.key]
		if not cmd
			return @write "unknown command: #{command.key}\n"

		# Display the help text
		@write "#{cmd[1]}\n"


# Export
if module?
	module.exports = CLI
else
	Codicle.CLI = CLI
