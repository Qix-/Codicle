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
		console.log "ACE TYPE:", chr

	arrow: (direction) ->
		console.log "ACE ARROW:", direction

	enter: () ->
		console.log "ACE ENTER"

	del: () ->
		console.log "ACE DELETE"

	backspace: () ->
		console.log "ACE BACKSPACE"

	pos: (row, col) ->
		console.log "ACE POS: #{row}:#{col}"


# Export
if module?
	module.exports = AceReceiverV1
else
	Codicle.ReceiverAce = AceReceiverV1
