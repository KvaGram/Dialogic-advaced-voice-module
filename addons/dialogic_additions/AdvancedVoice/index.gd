@tool
extends DialogicIndexer

func _get_events() -> Array:
	return [this_folder.path_join('event_advanced_voice.gd')]

func _get_subsystems() -> Array:
	return [{'name':'AdvancedVoice', 'script':this_folder.path_join('subsystem_advanced_voice.gd')}]

#TODO: add voice editor
func _get_editors() -> Array[String]:
	return [this_folder.path_join('Voicedata_editor.tscn')]
	#return []
