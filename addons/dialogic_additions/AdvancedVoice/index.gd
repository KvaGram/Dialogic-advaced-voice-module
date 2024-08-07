@tool
extends DialogicIndexer

func _get_events() -> Array:
	return [this_folder.path_join('event_advanced_voice.gd')]

func _get_subsystems() -> Array:
	return [{'name':'AdvancedVoice', 'script':this_folder.path_join('subsystem_advanced_voice.gd')}]

func _get_text_effects() -> Array[Dictionary]:
	return [
		{'command':'vclip', 'subsystem':'AdvancedVoice', 'method':'effect_vclip', 'arg':true},
		{'command':'vw', 'subsystem':'AdvancedVoice', 'method':'effect_vwait', 'arg':false},
	]
