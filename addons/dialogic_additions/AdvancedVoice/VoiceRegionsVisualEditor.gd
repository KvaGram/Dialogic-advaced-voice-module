class_name VoiceRegionsVisualEditor
extends DialogicVisualEditorField

var val:Dictionary
var _valid_text_regex:RegEx
const _valid_text_regex_pattern:String = "[^A-Z1-9\\.]"

func _ready():
	_valid_text_regex.compile(_valid_text_regex_pattern)

func _load_display_info(info:Dictionary) -> void:
	pass #not in use for now. Maybe never?


## To be overwritten
func _set_value(value:Variant) -> void:
	val = Dictionary(value)


## To be overwritten
func _autofocus() -> void:
	pass


func _on_newname_change(new_text):
	var c = %txt_newkey.caret_column #Location of the caret, or "text cursor"
	#make sure the name is valid. Only upper-case base english alpha-numerics. No space or special characters.
	new_text = new_text.to_upper() #converts to upper case
	if _valid_text_regex.search(new_text): #seraches for other illigal characters
		new_text = _valid_text_regex.sub(new_text, "", true) #removes illigal characters
	if %txt_newkey.text != new_text: #if changes are needed
		c += new_text.length() - %txt_newkey.text.length() #move caret if neccesary
		%txt_newkey.text = new_text
		%txt_newkey.caret_column = c


func _on_add_new_key(key:String):
	key = key.to_upper()
	if _valid_text_regex.search(key): #seraches for other illigal characters
		key = _valid_text_regex.sub(key, "", true) #removes illigal characters
	if val.has(key):
		#TODO add some kind of error feedback
		return
	addkey(key)
func addkey(key:String):
	if val.has(key):
		printerr("Unable to add key. key %s already exist." % key)
		return #this may be called from somewhere this is not already tested for.


func _on_btn_add_key_pressed():
	_on_add_new_key(%txt_newkey.text)


func _on_import():
	var clip = DisplayServer.clipboard_get()
	print(clip)
	#TODO: implement importer for Audacity
