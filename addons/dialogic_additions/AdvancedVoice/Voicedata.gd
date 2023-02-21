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
