@tool
extends Resource
class_name Voicedata

# Packages audiofile for voiceover with an index of dialog lines.
@export_file("*.mp3", "*.vaw", "*.ogg") var audio_file_path:String = ""
@export var startTimes : Array[float]
@export var stopTimes : Array[float]
@export var notes : Array[String]



#func __get_property_list() -> Array:
#	return []


func _to_string() -> String:
	return "[{name}:{id}]".format({"name":get_voicedata_name(), "id":get_instance_id()})

func _hide_script_from_inspector() -> bool:
	return true

## Returns the name of the file (without the extension).
func get_voicedata_name() -> String:
	return resource_path.get_file().trim_suffix('.dvd')

#need testing
func is_self(path):
	return self.resource_path == path

#future proofing for an advanced voicedata with multible audio files.
#This base version support only 1 audio stream.
func get_streams() -> Array[AudioStream]:
	var stream:AudioStream = ResourceLoader.load(audio_file_path, "AudioStream", ResourceLoader.CACHE_MODE_REUSE)
	return [stream]
#future proofing for an advanced voicedata with multible audio files.
#This base version support only 1 audio stream, so return is always index 0. 
func get_stream_index(_index:int)->int:
	return 0

func get_start(index:int)->float:
	if index < 0 or index >= startTimes.size():
		return 0.0
	else:
		return startTimes[index]
	
func get_stop(index:int)->float:
	if index < 0 or index >= stopTimes.size():
		return 0.0
	else:
		return stopTimes[index]

func get_notes(index:int)->String:
	if index < 0 or index >= notes.size():
		return "missing"
	else:
		return notes[index]
