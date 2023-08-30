@tool
extends Resource
class_name DialogicVoicedata

# Packages audiofile for voiceover with an index of dialog lines.
@export_file("*.mp3", "*.vaw", "*.ogg") var main_audio_path:String = ""
@export var voiceTimes : Array[Vector2]
@export var voiceNotes : Array[String] #Meta, notes on what a voice segments contains, to show in editor UIs.
@export var voiceKeys : Array[String] #index, decimal number in string, what a segment is 'named'.
@export var display_name : String #meta, name to show in editor UIs.
var previewData:PackedByteArray

func _init() -> void:
	main_audio_path = ""
	voiceTimes = []
	voiceNotes = []
	voiceKeys = []
	display_name = "unnamed voice data"
	previewData = PackedByteArray([0,0])
	resource_name = get_class()



#func __get_property_list() -> Array:
#	return []


func _to_string() -> String:
	return "[{name}:{id}]".format({"name":get_voicedata_name(), "id":get_instance_id()})

func getVoiceIndex(key:String)->int:
	return voiceKeys.find(key)

func makeEntryShortName(key:String)->String:
	var index = getVoiceIndex(key)
	if index < 0:
		return "%03s - missing" % [key]
	return "%03s - [%6.1f-%-6.1f] %s" % [key, voiceTimes[index].x, voiceTimes[index].y, (voiceNotes[index] if len(voiceNotes[index]) <= 20 else voiceNotes[index].substr(0,18) + "..")]
	


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

func getVoiceTime(key:String)->Vector2:
	var i = voiceKeys.find(key)
	if i < 0:
		return Vector2(-1,-1)
	return voiceTimes[i]

func getVoiceStart(key:String)->float:
	return getVoiceTime(key).x

func getVoiceStop(key:String)->float:
	return getVoiceTime(key).y

func getVoiceNotes(key:String)->String:
	var i = voiceKeys.find(key)
	if i < 0:
		return "missing"
	return voiceNotes[i]
	
