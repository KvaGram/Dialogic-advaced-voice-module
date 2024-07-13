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
	for key val.keys():
		pass



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
		printerr("Unable to add key. key %s already exist." % key)
		return
	val[key] = {'start':0.0, 'stop':0.0}
	_addKeyUI(key)


func _addKeyUI(key:String, start:float = 0, stop:float = 0):
	var n:Node
	for c:Node in %content.get_children(): #check if node exist
		if c.name == key:
			n = c
			break
	if not n:
		n = %template.duplicate()
		%content.add_child(n)
		n.name = key
		n.get_node('start').connect('value_changed', setStart.bind(key))
		n.get_node('stop').connect('value_changed', setStop.bind(key))
	n.get_node('start').set_value(start)
	n.get_node('stop').set_value(stop)


func removeKey(key:String):
	if not val.has(key):
		printerr("Unable to remove key. key %s not found." % key)
		return #this may be called from somewhere this is not already tested for.
func setStart(key, value):
	if not val.has(key):
		printerr("Unable to update start property. key %s not found." % key)
		return
	val[key]['start'] = value
func setStop(key, value):
	if not val.has(key):
		printerr("Unable to update stop property. key %s not found." % key)
		return
	val[key]['stop'] = value
func _on_btn_add_key_pressed():
	_on_add_new_key(%txt_newkey.text)


func _on_import():
	var clip = DisplayServer.clipboard_get()
	print(clip)
	#TODO: implement importer for Audacity
