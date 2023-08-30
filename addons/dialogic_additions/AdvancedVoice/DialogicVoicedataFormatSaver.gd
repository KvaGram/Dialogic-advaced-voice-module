@tool
extends ResourceFormatSaver
class_name DialogicVoicedataFormatSaver

func _get_recognized_extensions(resource: Resource) -> PackedStringArray:
	return PackedStringArray(["dvd"])

# Return true if this resource should be loaded as a DialogicVoicedata
func _recognize(resource: Resource) -> bool:
	# Cast instead of using "is" keyword in case is a subclass
	resource = resource as DialogicVoicedata
	
	if resource:
		return true
	
	return false

# Save the resource
func _save(resource: Resource, path: String = '', flags: int = 0):
	#print("saving resource %s to path %s"%[resource, path])
	var file := FileAccess.open(path, FileAccess.WRITE)
	var result := var_to_str(inst_to_dict(resource))
	file.store_string(result)
#	print('[Dialogic] Saved voicedata "' , path, '"')
