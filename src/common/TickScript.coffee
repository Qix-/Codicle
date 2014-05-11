#
# TickScript.coffee
#	Implements the TickScript specification
#

class TickScript
	##
	# @param script The script data to work from
	constructor: (@script) ->
		# Validate tickscript
		@validate()

		# Parse ticks
		@parse()

	##
	# Validates this Tickscript's contents
	validate: () ->
		if not @script.name or @script.name not instanceof String
			throw "TickScript name isn't string: #{@script.name}"
		if not @script.author or @script.author not instanceof String
			throw "TickScript author isn't string: #{@script.author}"
		if not @script.audio or @script.audio not instanceof String
			throw "TickScript audio track isn't string: #{@script.audio}"
		if not @script.bgm or @script.bgm not instanceof String
			throw "TickScript background music isn't string: #{@script.bgm}"
		if not @script.chapters or @script.chapters not instanceof Object
			throw "TickScript chapters is either empty or not a map"
		if not @script.ticks or @script.ticks not instanceof String
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
if module
	module.exports = TickScript
else
	Codicle.Script = TickScript