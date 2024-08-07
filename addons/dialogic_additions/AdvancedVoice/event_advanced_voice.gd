@tool
extends DialogicEvent
class_name DialogicAdvancedVoiceEvent

### Settings

## The path to the voicedata file.
var file_path: String = ""
## The volume the voice will be played at.
var volume: float = 0
## The audio bus to play the voice on.
var audio_bus: String = "Master"
var clip_data: Dictionary

func _execute() -> void:
	# NOTE: This event cannot be skipped.

	Dialogic.get_subsystem("AdvancedVoice").set_file(file_path)
	Dialogic.get_subsystem("AdvancedVoice").set_volume(volume)
	Dialogic.get_subsystem("AdvancedVoice").set_bus(audio_bus)
	Dialogic.get_subsystem("AdvancedVoice").set_clip_data(clip_data)
	finish()
	# the rest is executed by a text event


################################################################################
## 						INITIALIZE
################################################################################

func _init() -> void:
	event_name = "Advanced Voice"
	set_default_color('Color7')
	event_category = "Audio"
	event_sorting_index = 5
	expand_by_default = false



################################################################################
## 						SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "adv_voice"

func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name : property_info
		"path"		: {"property": "file_path", "default": ""},
		"volume"	: {"property": "volume", 	"default": 0},
		"bus"		: {"property": "audio_bus", "default": "Master"},
		"clip_data"	: {"property": "clip_data", "default": {'FULL' : {'start':0.00, 'stop':99999.99}}}
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()

################################################################################
## 						EDITOR REPRESENTATION
################################################################################

func build_event_editor():
	add_header_edit('file_path', ValueType.FILE, {
		'left_text'		: 'Set',
		'right_text'	: 'as the next voice audio',
		'file_filter'	: "*.mp3, *.ogg, *.wav",
		'placeholder' 	: "Select file",
		'editor_icon' 	: ["AudioStreamPlayer", "EditorIcons"]})
	add_body_edit('volume', ValueType.NUMBER, {'left_text':'Volume:', 'mode':2}, '!file_path.is_empty()')
	add_body_edit('audio_bus', ValueType.SINGLELINE_TEXT, {'left_text':'Audio Bus:'}, '!file_path.is_empty()')
	add_body_line_break('!file_path.is_empty()')
	add_body_edit('clip_data', ValueType.CUSTOM, {'path': "res://addons/dialogic_additions/AdvancedVoice/VoiceRegionsVisualEditor.tscn"}, '!file_path.is_empty()')


#### ADDED FOR DEBUG. SHOULD BE REMOVED
#
### returns a readable presentation of the event (This is how it's stored)
### by default it uses a shortcode format, but can be overridden
#func to_text() -> String:
	#print("saving adv voice event")
	#var result_string: String = "["+self.get_shortcode()
	#var params: Dictionary = get_shortcode_parameters()
	#var custom_defaults: Dictionary = DialogicUtil.get_custom_event_defaults(event_name)
	#for parameter in params.keys():
		#print("- saving ", parameter)
		#print("-- ", typeof(get(params[parameter].property)) )
		#print("-- ", typeof(custom_defaults.get(params[parameter].property, params[parameter].default)) )
		#print("-- ", get(params[parameter].property) )
		#print("-- ", custom_defaults.get(params[parameter].property, params[parameter].default) )
#
		#if (typeof(get(params[parameter].property)) != typeof(custom_defaults.get(params[parameter].property, params[parameter].default))) or \
		#(get(params[parameter].property) != custom_defaults.get(params[parameter].property, params[parameter].default)):
			#if typeof(get(params[parameter].property)) == TYPE_OBJECT:
				#print("-- saving an object")
				#result_string += " "+parameter+'="'+str(get(params[parameter].property).resource_path)+'"'
			#elif typeof(get(params[parameter].property)) == TYPE_STRING:
				#print("-- Saving a string")
				#result_string += " "+parameter+'="'+get(params[parameter].property).replace('=', "\\=")+'"'
			## if this is an enum with values provided, try to use a text alternative
			#elif typeof(get(params[parameter].property)) == TYPE_INT and params[parameter].has('suggestions'):
				#print("-- saving a enum")
				#for option in params[parameter].suggestions.call().values():
					#if option.value == get(params[parameter].property):
						#if option.has('text_alt'):
							#result_string += " "+parameter+'="'+option.text_alt[0]+'"'
						#else:
							#result_string += " "+parameter+'="'+var_to_str(option.value).replace('=', "\\=")+'"'
						#break
			#elif typeof(get(params[parameter].property)) == TYPE_DICTIONARY:
				#print("-- saving a dictionary")
				#result_string += " "+parameter+'="'+ JSON.stringify(get(params[parameter].property)).replace('=', "\\=")+'"'
			#else:
				#print("-- saving a primitive value")
				#result_string += " "+parameter+'="'+var_to_str(get(params[parameter].property)).replace('=', "\\=")+'"'
		#print("-- end of ", parameter)
	#result_string += "]"
	#return result_string
