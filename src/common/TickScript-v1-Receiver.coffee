#
# Tickscript-v1-Receiver.coffee
#	Handles actions/focus for the v1 TickScript spec
#

class ReceiverV1
	##
	# @param editor The ACE editor to manipulate
	# @param console The console handler to manipulate
	constructor: (editor, @console) ->
		# Setup editor/console receivers
		@editor = new Codicle.ReceiverAce editor

		# Focus the editor by default
		#	with a fallback of the console
		@focused = @editor || @console
		if not @focused?
			throw "Both editor and console are null for receiver"
		@focused.focus() if @focused.focus

		# Setup last command
		#	Used by repeat
		#	[fn, {args}]
		@lastCmd = []

	################################################
	# TICKSCRIPT COMMANDS
	################################################

	type: (chr) ->
		@lastCmd = ['type', arguments]
		if @focused is @console and chr is '\t'
			@console.autoComplete()
		else
			@focused.type chr

	arrow: (direction) ->
		@lastCmd = ['arrow', arguments]
		if @focused is @console
			switch direction
				when 0 then @console.lastCommand()
				when 2 then @console.nextCommand()
				when 1 then @console.right()
				when 3 then @console.left()
		else
			@focused.arrow direction
		return

	repeat: (times) ->
		return if not @lastCmd or not @lastCmd.length
		args = [].slice.call @lastCmd[1]
		@[@lastCmd[0]].apply @, args for [1..times]
		return

	enter: () ->
		@lastCmd = ['enter', arguments]
		if @focused is @console then @console.execute()
		else @focused.enter()

	del: () ->
		@lastCmd = ['del', arguments]
		@focused.del()

	backspace: () ->
		@lastCmd = ['backspace', arguments]
		@focused.backspace()

	pos: (row, col) ->
		@lastCmd = ['pos', arguments]
		if @focused is @console then @console.col col
		else @focused.pos row, col

	focus: (component) ->
		@lastCmd = ['focus', arguments]
		@focused.blur() if @focused.blur
		@focused =
			switch component
				when 'presentation' then @console
				when 'editor' then @editor
		@focused.focus() if @focused.focus

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
