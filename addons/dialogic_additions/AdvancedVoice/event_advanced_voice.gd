@tool
extends DialogicEvent
class_name DialogicAdvancedEvent

### Settings

## The path to the voicedata file.
var file_path: String = ""
## The volume the voice will be played at.
var volume: float = 0
## The audio bus to play the voice on.
var audio_bus: String = "Master"

func _execute() -> void:
	# This will execute when the event is reached
	finish() # called to continue with the next event


################################################################################
## 						INITIALIZE
################################################################################

func _init() -> void:
	event_name = "Advanced Voice"
	set_default_color('Color1')
	event_category = Category.AudioVisual
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
		"bus"		: {"property": "audio_bus", "default": "Master"}
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()

################################################################################
## 						EDITOR REPRESENTATION
################################################################################

func build_event_editor():
	add_header_edit('file_path', ValueType.File, '', 'is the audio for the next text', 
			{'file_filter'	: "*.mp3, *.ogg, *.wav", 
			'placeholder' 	: "Select file", 
			'editor_icon' 	: ["AudioStreamPlayer", "EditorIcons"]})
	add_body_edit('volume', ValueType.Decibel, 'volume:', '', {}, '!file_path.is_empty()')
	add_body_edit('audio_bus', ValueType.SinglelineText, 'audio_bus:', '', {}, '!file_path.is_empty()')
