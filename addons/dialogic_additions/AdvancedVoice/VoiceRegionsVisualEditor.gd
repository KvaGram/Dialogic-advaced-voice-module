@tool
extends DialogicVisualEditorField
class_name VoiceRegionsVisualEditor

var val:Dictionary
var _valid_text_regex:RegEx
const _valid_text_regex_pattern:String = "[^A-Z1-9\\.]"
var dialog:AcceptDialog
var import_data:Dictionary

func _ready():
	_valid_text_regex = RegEx.new()
	_valid_text_regex.compile(_valid_text_regex_pattern)
	dialog = AcceptDialog.new()
	add_child(dialog)
	dialog.confirmed.connect(_on_import_confirmed)
	dialog.canceled.connect(_on_import_abort)

func _load_display_info(info:Dictionary) -> void:
	pass #not in use for now. Maybe never?

func signal_update():
	value_changed.emit(property_name, val)

func _set_value(value:Variant) -> void:
	if value:
		val = value
	else:
		val = {'FULL' : {'start':0.00, 'stop':99999.99}}
	for c:Node in %content.get_children():
		c.queue_free()
	for key in val.keys():
		_addKeyUI(key, val[key]["start"], val[key]["stop"])



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
	signal_update()


func _addKeyUI(key:String, start:float = 0, stop:float = 0):
	var n:Node
	for c:Node in %content.get_children(): #check if node exist
		if c.name == key:
			n = c
			break
	#print("adding key ", key)
	if not n:
		n = %template.duplicate()
		%content.add_child(n)
		n.name = key
		n.visible = true
		n.get_node('label_key').text = key
		n.get_node('start').connect('value_changed', setStart.bind(key))
		n.get_node('stop').connect('value_changed', setStop.bind(key))
		n.get_node('btn_remove').pressed.connect(removeKey.bind(key))
	n.get_node('start').set_value(start)
	n.get_node('stop').set_value(stop)


func removeKey(key:String):
	if not val.has(key):
		printerr("Unable to remove key. key %s not found." % key)
		return #this may be called from somewhere this is not already tested for.
	var n:Node = %content.get_node(key)
	n.queue_free()
	val.erase(key)
	signal_update()

func setStart(_p_name, value, key):
	if not val.has(key):
		printerr("Unable to update start property. key %s not found." % [key])
		return
	val[key]['start'] = value
	signal_update()
func setStop(_p_name, value, key):
	if not val.has(key):
		printerr("Unable to update stop property. key %s not found." % [key])
		return
	val[key]['stop'] = value
	signal_update()
func _on_btn_add_key_pressed():
	_on_add_new_key(%txt_newkey.text)

func _on_import_abort():
	import_data = {}

func _on_import_confirmed():
	val.merge(import_data, true)
	set_value(val) #Yeah I know. Quick and lazy.
	signal_update()

func on_import_audacity(text:String):
	var d = {}
	var lines:PackedStringArray = text.split("\n", false)
	for l:String in lines:
		var flag_abort:bool = false
		var entry = l.split("\t", false)
		if entry.size() < 2:
			continue # skipping
		## Read start and stop
		var start:float = entry[0].to_float()
		var stop:float = entry[1].to_float()
		## read the key/label
		var key = ""
		#An audacity label is technically optional, so check if it exist.
		if entry.size() >= 3:
			key = entry[2].to_upper() #Import the name, in upper-case
			if _valid_text_regex.search(key): #seraches for other illigal characters
				key = _valid_text_regex.sub(key, "", true) #removes illigal characters
			key = key.substr(0,5) #cuts name down to maximum 5 characters
		if len(key) < 1:
			key = "X" #if name does not exist,or consisted entirely if illigal characters, name it X
		if len(key) < 2: #For a length less than 2, add a 0
			key +="0"
		var k2 = key
		var i:int = 0
		#test if the name already exists amung imported entries
		#if it does, keep incrementing a number untill we get a unique name.
		#If we reach 999 potential keynames, wow that's a lot of audacity labels, just give up.
		#Note this makes it possible to have key names up to 8 characters in length in total for an edge case.
		while(k2 in d):
			if i > 999:
				flag_abort = true
				break
			k2 = key + str(i)
			i += 1
		if flag_abort:
			continue
		key = k2
		d[key] = {'start':start, 'stop':stop} #add imported entry
	if len(d) > 0:
		import_data = d

func _on_import():
	var clip = DisplayServer.clipboard_get()
	on_import_audacity(clip)
	#print(clip)
	dialog.title = "(TEST) Importing voice clip regions from clipboard"
	if len (import_data) < 1:
		dialog.dialog_text ="No importable data found on clipboard."
		return

	dialog.dialog_text ="""
This importer currently only supports data from Audacity.
The following data has been read from your clipboard:
%s
""" % [_stringify_data(import_data)]
	var conflicts:Dictionary = {}
	for k in import_data.keys():
		if k in val.keys():
			conflicts[k] = val[k]
	if conflicts.size()>0:
		dialog.dialog_text +="""
The following existing entries match one or more keys in the imported data
Going ahead with the import will override these entries.
%s
""" % [_stringify_data(conflicts)]

	dialog.popup_centered_ratio(0.3)
func _stringify_data(data:Dictionary)->String:
	var ret:String = ""
	for k in data.keys():
		ret += "\n %s - start: %s - stop: %s" % [k, data[k].get('start', 0), data[k].get('stop', 0)]
	return ret
