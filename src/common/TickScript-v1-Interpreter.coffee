#
# TickScript-v1-Interpreter.coffee
#	V1 specification implementation that
#	converts commands into actions.
#

class TickScriptV1
	##
	# @param commands The commands parsed
	#				  from a tickscript v1 string
	# @param receiver The receiver that should handle commands
	constructor: (commands, receiver) ->
		# Compile events
		@events = []
		@compile commands, receiver

	##
	# Compiles commands down to
	#	bound functions
	# @param commands The commands to compile
	# @param receiver The receiver to bind to
	compile: (commands, receiver) ->
		for command in commands
			fn = receiver[command[1]]
			args = command[2]
			bound = fn.bind.apply fn, [receiver].concat args
			@events.push [command[0], bound]

# Export
if module?
	module.exports = TickScriptV1
else
	Codicle.Interpreter = TickScriptV1
