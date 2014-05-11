#
# Tickscript-v1-Receiver.coffee
#	Handles actions/focus for the v1 TickScript spec
#

class ReceiverV1
	##
	# @param editor The ACE editor to manipulate
	# @param console The console handler to manipulate
	constructor: (@editor, @console) ->
		# Focus the editor by default
		#	with a fallback of the console
		@focus = @editor || @console
		if not @focus?
			throw "Both editor and console are null for receiver"

		# Setup last command
		#	Used by repeat
		#	[fn, {args}]
		@lastCmd = []

	################################################
	# TICKSCRIPT COMMANDS
	################################################

	type: (chr) ->
		@lastCmd = ['type', arguments]
		@focus.type chr

	arrow: (direction) ->
		@lastCmd = ['arrow', arguments]
		if @focus is @console
			switch direction
				when 0 then @console.lastCommand()
				when 2 then @console.nextCommand()
				when 1 then @console.right()
				when 3 then @console.left()
		else
			@focus.arrow direction
		return

	repeat: (times) ->
		return if not @lastCmd or not @lastCmd.length
		args = [].slice.call @lastCmd[1]
		@lastCmd[0].apply @, args for [1..times]
		return

	enter: () ->
		@lastCmd = ['enter', arguments]
		if @focus is @console then @console.execute()
		else @focus.enter()

	del: () ->
		@lastCmd = ['del', arguments]
		@focus.del()

	backspace: () ->
		@lastCmd = ['backspace', arguments]
		@focus.backspace()

	pos: (row, col) ->
		@lastCmd = ['pos', arguments]
		if @focus is @console then @console.col col
		else @focus.pos row, col

	focus: (component) ->
		@lastCmd = ['focus', arguments]
		@focus =
			switch component
				when 'presentation' then @console
				when 'editor' then @editor

	pause: () ->
		@lastCmd = ['pause', arguments]
		console.log 'pause not implemented yet'

	wait: () ->
		@lastCmd = ['wait', arguments]
		console.log 'wait (for console) not implemented yet'

# Export
if module?
	module.exports = ReceiverV1
else
	Codicle.Receiver = ReceiverV1
