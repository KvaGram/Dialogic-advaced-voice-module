extends DialogicSubsystem
## Subsystem that manages setting voice lines for text events.
##
## It's recommended to use the [class DialogicVoiceEvent] to set the voice lines
## for text events and not start playing them directly.


## Emitted whenever a new voice line starts playing.
## The [param info] contains the following keys and values:
## [br]
## Key      |   Value Type  | Value [br]
## -------- | ------------- | ----- [br]
## `file`   | [type String] | The path to file played. [br]
## 'key		| [type String] | The voiceclip key played. [br]
## `start`	| [type float]  | Timestamp played from. [br]
## `stop`   | [type float]  | Timestamp clip ends. [br]

signal voicelip_started(info: Dictionary)


## Emitted whenever a voice line finished playing.
## The [param info] contains the following keys and values:
## [br]
## Key              |   Value Type  | Value [br]
## ---------------- | ------------- | ----- [br]
## `file`           | [type String] | The path to file played. [br]
## `remaining_time` | [type float]  | The remaining time of the voiceline. [br]
#signal voiceline_finished(info: Dictionary)


## Emitted whenever a voice line gets interrupted and does not finish playing.
## The [param info] contains the following keys and values:
## [br]
## Key              |   Value Type  | Value [br]
## ---------------- | ------------- | ----- [br]
## `file`           | [type String] | The path to file played. [br]
## `remaining_time` | [type float]  | The remaining time of the voiceline. [br]
#signal voiceline_stopped(info: Dictionary)


## The current audio file being played.
var current_audio_file: String

## The audio player for the voiceline.
var voice_player := AudioStreamPlayer.new()

## The current voice timer, used to stop playback at the end of a voice clip
var voice_timer:Timer

## the current clip data, used to define when a clip starts and when it ends
var current_clip_data:Dictionary

#region MAIN METHODS
####################################################################################################
func _ready() -> void:
	add_child(voice_player)

func play_voice(key:String):
	voice_player.stream = ResourceLoader.load_threaded_get(current_audio_file)
	if not current_clip_data.has(key):
		printerr("Advanced voice: Cannot find key %s in current voice data. Aborting voiceclip")
		return
	var start:float = current_clip_data[key].get('start')
	var stop:float = current_clip_data[key].get('stop')

	voice_player.play(start)
	set_timer(stop - start)
	voicelip_started.emit({'file': current_audio_file, 'key': key, 'start' : start, 'stop' : stop})

func set_file(path:String):
	current_audio_file = path
	ResourceLoader.load_threaded_request(path, "AudioStream") #load early for less delay. File remains in ResourceLoader.
func set_clip_data(data:Dictionary):
	current_clip_data = data

func set_volume(value:float):
	voice_player.volume_db = value

func set_bus(value:String):
	voice_player.bus = value

func stop_audio():
	voice_player.stop()
	voice_timer.stop()

func set_timer(time:float):
	if !voice_timer:
		voice_timer = Timer.new()
		DialogicUtil.update_timer_process_callback(voice_timer)
		voice_timer.one_shot = true
		add_child(voice_timer)
		voice_timer.timeout.connect(stop_audio)
	voice_timer.stop()
	voice_timer.start(time)

func get_remaining_time() -> float:
	if not voice_timer or voice_timer.is_stopped():
		return 0.0 #contingency
	return voice_timer.time_left

func is_running() -> bool:
	return get_remaining_time() > 0.0
#endregion

#region DEFAULT TEXT EFFECTS & MODIFIERS
################################################################################
func effect_vclip(text_node:Control, skipped:bool, argument:String) -> void:
	if voice_player.playing:
		pass

#endregion

#region STATE
####################################################################################################

## Stops the current voice from playing.
func pause() -> void:
	voice_player.stream_paused = true
	voice_timer.paused = true


## Resumes a paused voice.
func resume() -> void:
	voice_player.stream_paused = false
	voice_timer.paused = false

#endregion
