#
# TickScript-v1-Receiver-Ace.coffee
#	Receives events for the ACE editor and translates
#	them to API calls
#

class AceReceiverV1
	##
	# @param ace The Ace editor instance
	constructor: (@ace) ->

	type: (chr) ->
		@ace.onTextInput chr

	arrow: (direction) ->
		switch direction
			when 0 then @ace.navigateUp 1
			when 1 then @ace.navigateRight 1
			when 2 then @ace.navigateDown 1
			when 3 then @ace.navigateLeft 1

	enter: () ->
		@type '\n'

	del: () ->
		# Found this by doing editor.keyBinding
		#	after doing editor.onTextInput (with no parens)
		#	in a debugging console. Ace has poor documentation.
		@ace.remove 'right'

	backspace: () ->
		# Found this by doing editor.keyBinding
		#	after doing editor.onTextInput (with no parens)
		#	in a debugging console. Ace has poor documentation.
		@ace.remove 'left'

	pos: (row, col) ->
		@ace.getSession().selection.moveTo row, col


# Export
if module?
	module.exports = AceReceiverV1
else
	Codicle.ReceiverAce = AceReceiverV1
