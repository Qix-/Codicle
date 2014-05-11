#
# TickScript-v1-Interpreter.coffee
#	V1 specification implementation that
#	converts commands into actions.
#

class TickScriptV1
	##
	# @param commands The commands parsed
	#				  from a tickscript v1 string
	constructor: (commands) ->
		# Compile events
		@events = []
		@compile commands

	##
	# Compiles commands down to
	#	bound functions
	# @param commands The commands to compile
	compile: (commands) ->
		for command in commands
			fn = @[command[1]]
			args = command[2]
			bound = fn.bind.apply fn, [@].concat args
			@events.push [command[0], bound]

	################################################
	# TICKSCRIPT COMMANDS
	################################################

	type: (chr) ->
		console.log 'type:', chr

	arrow: (direction) ->
		console.log 'arrow:', direction

	repeat: (times) ->
		console.log 'repeat:', times

	enter: () ->
		console.log 'enter'

	del: () ->
		console.log 'delete'

	backspace: () ->
		console.log 'backspace'

	pos: (row, col) ->
		console.log "pos: #{row}, #{col}"

	focus: (component) ->
		console.log 'focus:', component

	pause: () ->
		console.log 'pause'

	wait: () ->
		console.log 'wait (for console)'

# Export
if module?
	module.exports = TickScriptV1
else
	Codicle.Interpreter = TickScriptV1
