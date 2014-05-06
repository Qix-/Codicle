#
# Player.coffee
#	Main Codicle player class
#

class CodiclePlayer
	##
	# @param editor The editor element to select
	# @param presentation The presentation element to select
	construct: (editor = "#editor", presentation = "#presentation") ->
		# Select frame elements
		@editor = document.querySelector editor
		@presentation = document.querySelector presentation
		throw "Editor element doesn't exist: #{editor}" if not @editor
		throw "Presentation element doesn't exist: #{presentation}" if not @presentation
