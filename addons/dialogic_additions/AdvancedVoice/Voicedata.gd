@tool
extends Resource
class_name Voicedata

# Packages audiofile for voiceover with an index of dialog lines.
@export_file("*.mp3", "*.vaw", "*.ogg") var main_audio_path:String = ""
@export var startTimes : Array[float] #Data, time in secunds where a voice segment begins
@export var stopTimes : Array[float] #Data, time in secunds where a voice segment ends
@export var notes : Array[String] #Meta, notes on what a voice segments contains, to show in editor UIs.
@export var keys : Array[String] #index, decimal number in string, what a segment is 'named'.
@export var display_name : String #meta, name to show in editor UIs.




#func __get_property_list() -> Array:
#	return []


func _to_string() -> String:
	return "[{name}:{id}]".format({"name":get_voicedata_name(), "id":get_instance_id()})

func getIndex(key:String)->int:
	return keys.find(key)

func makeEntryShortName(key:String)->String:
	var index = getIndex(key)
	if index < 0:
		return "%03s - missing" % [key]
	return "%03s - [%6.1f-%-6.1f] %s" % [key, startTimes[index], stopTimes[index], (notes[index] if len(notes[index]) <= 20 else notes[index].substr(0,18) + "..")]
	


func _hide_script_from_inspector() -> bool:
	return true

## Returns the name of the file (without the extension).
func get_voicedata_name() -> String:
	return resource_path.get_file().trim_suffix('.dvd')

#need testing
func is_self(path):
	return self.resource_path == path

#future proofing for an advanced voicedata, possebly with multible audiostreams.
#This base version support only 1 audio stream.
func get_streams() -> Array[AudioStream]:
	var stream:AudioStream = ResourceLoader.load(main_audio_path, "AudioStream", ResourceLoader.CACHE_MODE_REUSE)
	return [stream]
#Return the paths for the audio-streams. In this base version, there is only 1.
func get_stream_path(_index:int)->String:
	return main_audio_path
#Returns how many audiostreams this data has.
#For this base version, there is only 1.
func get_num_audio()->int:
	return 1

#Gets the index of the stream to use for the requested index and variant.
#In this base version there is only 1, so returns index 0.
func get_stream_index(_index:int, _variant:int)->int:
	return 0
#gets the start time in secunds for the given index and variant.
#variant is not used in this base version. And so only loads from startTimes.
func get_start(index:int, _variant:int)->float:
	if index < 0 or index >= startTimes.size():
		return 0.0
	else:
		return startTimes[index]
		
#gets the stop time in secunds for the given index and variant.
#variant is not used in this base version. And so only loads from stopTimes.
func get_stop(index:int, _variant:int)->float:
	if index < 0 or index >= stopTimes.size():
		return 0.0
	else:
		return stopTimes[index]
#gets the notes/comments/hints for the given index and variant.
#variant is not used in this base version. And so only loads from notes.
func get_notes(index:int, _variant:int)->String:
	if index < 0 or index >= notes.size():
		return "missing"
	else:
		return notes[index]
