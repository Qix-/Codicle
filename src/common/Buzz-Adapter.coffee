#
# Buzz-Adapter.coffee
#	Wraps Buzz functionality
#

class BuzzAdapter
	##
	# @param vox Url to vocal mix (no extension)
	# @param bgm Url to BGM mix (no extension)
	constructor: (vox, bgm) ->
		# Determine supported audio format
		#	We prefer OGG over MP3 here.
		if not buzz.isSupported()
			# TODO Alert the user
			throw "Audio not supported!"
		
		switch
			when buzz.isOGGSupported() then format = 'ogg'
			when buzz.isMP3Supported() then format = 'mp3'
			# TODO Alert the user
			else throw "Audio formats not supported!"

		# Generate sound objects
		@voxSound = new buzz.sound "#{vox}.#{format}"
			, preload: 'auto'
		@bgmSound = new buzz.sound "#{bgm}.#{format}"
			, {
				preload: 'auto'
				loop: true
				}

		# Set playing flag
		@playing = false

		# Create group
		@sound = new buzz.group @voxSound, @bgmSound

	##
	# Preloads the audio files and calls back when they're complete
	preload: (callback) ->
		preloaded = 2
		onload = () ->
			--preloaded;
			callback() if preloaded is 0

		if @voxSound.getStateCode() is 'HAVE_ENOUGH_DATA'
			onload()
		else
			@voxSound.bindOnce 'canplaythrough', onload
			@voxSound.load()

		if @bgmSound.getStateCode() is 'HAVE_ENOUGH_DATA'
			onload()
		else
			@bgmSound.bindOnce 'canplaythrough', onload
			@bgmSound.load()

	##
	# Pauses audio
	pause: () ->
		return if not @playing
		@sound.fadeOut 400, () =>
			@sound.pause()
		@playing = not @playing

	##
	# Resumes audio
	resume: () ->
		return if @playing
		@voxSound.fadeIn 400
		@bgmSound.fadeTo 30, 400
		@playing = not @playing

	##
	# Turns on/off the BGM music
	# @param enabled Whether or not to play the background music
	setBGMEnabled: (enabled = true) ->
		@bgmSound.setVolume (if enabled then 30 else 0)

	##
	# Seeks to a position
	# @param percent A percentage to seek to
	seek: (percent = 0.0) ->
		@voxSound.setPercent percent

	##
	# Gets the time in seconds of the
	#	vocal clip
	getTime: () ->
		@voxSound.getTime()

# Export
if module?
	module.exports = BuzzAdapter
else
	Codicle.Buzz = BuzzAdapter