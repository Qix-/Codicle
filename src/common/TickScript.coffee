#
# TickScript.coffee
#	Implements the TickScript specification
#

class TickScript
	##
	# @param script The script data to work from
	# @param editor A handle to the Ace editor
	constructor: (@script, editor) ->
		# Validate tickscript
		@validate()

		# Parse ticks
		@parse()

		# Create receiver
		@receiver =
			new Codicle.Receiver {}, {}

		# Create commander
		@commands =
			new Codicle.Interpreter @commands, @receiver

		# Log
		console.log "Enumerated #{@commands.events.length} ticks"

	##
	# Validates this Tickscript's contents
	validate: () ->
		if not @script.version or typeof @script.version isnt 'string'
			throw "TickScript version isn't string: #{@script.version}"
		if not @script.name or typeof @script.name isnt 'string'
			throw "TickScript name isn't string: #{@script.name}"
		if not @script.author or typeof @script.author isnt 'string'
			throw "TickScript author isn't string: #{@script.author}"
		if not @script.audio or typeof @script.audio isnt 'string'
			throw "TickScript audio track isn't string: #{@script.audio}"
		if not @script.bgm or typeof @script.bgm isnt 'string'
			throw "TickScript background music isn't string: #{@script.bgm}"
		if not @script.chapters or @script.chapters not instanceof Object
			throw "TickScript chapters is either empty or not a map"
		if not @script.ticks or typeof @script.ticks isnt 'string'
			throw "TickScript ticks isn't a string: #{@script.ticks}"

	##
	# Parses the ticks in this TickScript's ticks string
	#	This expands times to absolute times, making use
	#	of the parser compiled from the Peg.JS grammar.
	parse: () ->
		# Try to parse
		@commands = TSParser.parse @script.ticks

		# Check
		if not @commands
			throw "Tickscript ticks could not be parsed"


# Export
if module?
	module.exports = TickScript
else
	Codicle.Script = TickScript