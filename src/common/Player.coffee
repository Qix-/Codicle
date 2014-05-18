#
# Player.coffee
#   Handles playback of the lesson including audio
#   and script automation
#

class Player
    ##
    # @param script The TickScript to play
    constructor: (@script) ->
        # Create buzz adapter
        @buzz = new Codicle.Buzz @script.getVoxUrl(), @script.getBgmUrl()
        
        # Setup flags
        @lastScrub = 0.0
        @interval = null
        
    ##
    # Reconstucts the lesson contents
    #   given a time
    # @param time A time in seconds
    scrub: (time) ->
        @script.reset()
        for cmd in @script.commands.events
            break if cmd[0] > time
            cmd[1]()
        
    ##
    # Executes a chunk of instructions
    #   from a beginning range to an ending range
    #   NOTE: does not reset
    # @param begin The beginning time (exclusive)
    # @param end The ending time (inclusive)
    scrubRange: (begin, end) ->
        for cmd in @script.commands.events when begin < cmd[0] <= end
            cmd[1]()
     
    ##
    # Updates the UI using a scrub range
    updateUI: () ->
        location = @buzz.getTime()
        if @lastScrub > location
            @scrub location
        else
            @scrubRange @lastScrub, location
        @lastScrub = location 
    
    ##
    # Resumes (or starts) playback
    resume: () ->
        return if @interval
        @buzz.resume()
        updateFunc = () =>
            @updateUI()
        @interval = setInterval updateFunc, 10

    ##
    # Pauses the playback
    pause: () ->
        return if not @interval
        @buzz.pause()
        clearInterval @interval
        @interval = null
    
    ##
    # Whether or not the lesson is playing
    isPlaying: () ->
        @interval isnt null
    
    ##
    # Seeks to a certain percentage
    # @param percent The perent (0.0 - 1.0) to seek to
    seek: (percent) ->
        wasPlaying = @isPlaying()
        clearInterval @interval if wasPlaying
        @buzz.seek percent
        @scrub @buzz.getTime()
        updateFunc = () =>
            @updateUI()
        @interval = setInterval updateFunc, 10 if wasPlaying

    ##
    # Loads any and all assets necessary
    #   to play the lesson
    # @param callback The callback to call when the player is finished
    load: (callback) ->
        @buzz.preload callback
            
# Export
if module?
    module.exports = Player
else
    Codicle.Player = Player