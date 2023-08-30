##TODO:
#Use dicts to story region entries, but restrict names to decimals
#Add a create a split-entry button "did you suddenly need to split this line in two or more?"

@tool
extends DialogicEditor

var plugin_reference:EditorPlugin
var loading:bool #safety flag, prevents accidental saving
#var segmentPanelNode:PackedScene = preload("res://addons/dialogic_additions/AdvancedVoice/VoiceSegmentPanel.tscn")
var audio:AudioStream
#var audio_previews:Array[Texture2D]

#data refrences current_resource, but with a Voicedata type-hint
var data:DialogicVoicedata 
var sel_key:String = "-1"
var true_index:int = 0
var keys_local:Array[String] = [] #keys in order they appear in %listEntries

var valid_text_regex:RegEx
const valid_text_regex_pattern:String = "[^A-Z1-9\\.]"

@onready var timeline:VoicedataTimeline = %timeline

###TODO: attempt to recreate a preview generator by adding a muted audiobus, and recording it's local volume.


##############################################################################
##							RESOURCE LOGIC
##############################################################################

# Method is called once editors manager is ready to accept registers.
func _register() -> void:
	resource_unsaved.connect(_on_resource_unsaved)
	resource_saved.connect(_on_resource_saved)
	# Makes the editor open this when a .dvd file is selected.
	# Then _open_resource() is called.
	editors_manager.register_resource_editor("dvd", self)
	# Add a "add voicedata" button
	var add_voicedata_button = editors_manager.add_icon_button( 
			load("res://addons/dialogic_additions/AdvancedVoice/icon.png"),
			'Add voicedata',
			self)
	add_voicedata_button.pressed.connect(
			editors_manager.show_add_resource_dialog.bind(
			new_voicedata, 
			'*.dvd; DialogicVoicedata',
			'Create new voice data',
			'new voice data',
			))


# Called when a character is opened somehow
func _open_resource(resource:Resource) -> void:
	# update resource
	current_resource = (resource as DialogicVoicedata)
	data = current_resource
	
	# make sure changes in the ui won't trigger saving
	loading = true
	audio = load(data.main_audio_path)
	var n:Control
	#preview data is a PackedByteArray with two datapoints (stereo) per decisecund of sound
	if(audio):
		timeline.set_stream(audio, data.previewData)
	reload_list()
	
	#maybe todo: add support for multible audiostreams
	#plugin_reference.get_editor_interface().get_resource_previewer().queue_resource_preview(current_resource.get_stream_path(0),self, &"_on_preview_recived",0)
	
	
	
	#(...)
	#Add signal?
	#voicedata_loaded.emit(resource.resource_path)
	loading = false

	#maybe todo: add support for multible audiostreams
#func _on_preview_recived(_path:String, preview:Texture2D, _thumbnail_preview:Texture2D, _userdata):
#	audio_previews[0] = preview
#	%timeline_texture.texture = preview

#func on_move_segment(old_i, new_i):
#	%boxSegments.move_child(%boxSegments.get_child(old_i), new_i)
#	#Segments must be reloaded to refrect their new data
#	reload_list()
#	something_changed()

#func on_new_segment():
#	var c = segmentPanelNode.instantiate()
#	%boxSegments.add_child(c)
#	something_changed()

#clears and reloads 
func reload_list():
	%listEntries.clear()
	keys_local.clear()
	var data:DialogicVoicedata = current_resource as DialogicVoicedata
	if not data:
		%FilePickerAudio.set_value("")
		return
	%FilePickerAudio.set_value(data.main_audio_path)
	keys_local = data.voiceKeys.duplicate()
	keys_local.sort()
	for k in keys_local:
		var i:int = %listEntries.add_item(data.makeEntryShortName(k))
	if sel_key in keys_local:
		selectEntryKey(sel_key)
	else:
		selectEntry(0)

#refresh names of items in listEntries
func refresh_list():
	for i in range(keys_local.size()):
		var k = keys_local[i]
		%listEntries.set_item_text(i, data.makeEntryShortName(k))

func selectEntry(i:int):
	var key = keys_local[i] if i < keys_local.size() else ""
	#var key = %listEntries.get_item_metadata(i)
	if key.length() < 1:
		disable_entry_edit()
		return
	selectEntryKey(key)
	
func getSelIndex()->int:
	return -1 if not %listEntries.is_anything_selected() else %listEntries.get_selected_items()[0]

func selectEntryKey(key:String = ""):
	if not key in keys_local:
		disable_entry_edit()
		return
	var i = data.getIndex(key)
	var li = keys_local.find(key)
	if i < 0:
		print("voice segment %s not found on file"%[i])
		disable_entry_edit()
		return
	if li < 0:
		printerr("voice segment %s found on file, but not editor. This should not happen"%[li])
		disable_entry_edit()
		return
	loading = true
	sel_key = key
	
	print("data start[i] ", data.startTimes[i])
	
	%entryKey.text = key
	%entryKey.editable = true
	%spinStartTime.value = data.startTimes[i]
	timeline.selectedmarker.x = data.startTimes[i]
	%spinStartTime.editable = true
	%spinStopTime.value = data.stopTimes[i]
	timeline.selectedmarker.y = data.stopTimes[i]
	%spinStopTime.editable = true
	%txtNotes.text = data.voiceNotes[i]
	%txtNotes.editable = true
	
	if keys_local[getSelIndex()] != key:
		%listEntries.select(li)
	if audio:
		%spinStartTime.max_value = audio.get_length()-0.1
		%spinStartTime.min_value = 0
		%spinStopTime.max_value  = audio.get_length()
		%spinStopTime.min_value = max(0.1, %spinStartTime.value+0.1)
	else:
		print("Please load an audiofile")
	
	loading = false
func disable_entry_edit():
	sel_key = ""
	loading = true
	%entryKey.text = ""
	%entryKey.editable = false
	%spinStartTime.value = 0
	%spinStartTime.editable = false
	%spinStopTime.value = 0
	%spinStopTime.editable = false
	%txtNotes.text = "Hello world"
	%txtNotes.editable = false
	loading = false

func _save_resource() -> void:
	if loading or not visible or not current_resource:
		return
#	var size = %boxSegments.get_child_count()
#	if current_resource.startTimes.size() != size:
#		current_resource.startTimes.resize(size)
#		current_resource.stopTimes.resize(size)
#		current_resource.notes.resize(size)
#
#	for c in %boxSegments.get_children():
#		var i = c.get_index()
#		current_resource.startTimes[i] = c.get_start()
#		current_resource.stopTimes[i] = c.get_stop()
#		current_resource.notes[i] = c.get_notes()
		
	#TODO: save audiopath
	
	#example code from character editor. Mimic and adapt for voicedata.	
#	# Portrait list
#	current_resource.portraits = get_updated_portrait_dict()
#
#	# Portrait settings
#	if %DefaultPortraitPicker.current_value in current_resource.portraits.keys():
#		current_resource.default_portrait = %DefaultPortraitPicker.current_value
#	elif !current_resource.portraits.is_empty():
#		current_resource.default_portrait = current_resource.portraits.keys()[0]
#	else:
#		current_resource.default_portrait = ""
#
#	current_resource.scale = %MainScale.value/100.0
#	current_resource.offset = Vector2(%MainOffsetX.value, %MainOffsetY.value) 
#	current_resource.mirror = %MainMirror.button_pressed
#
#	# Main tabs
#	for main_edit in %MainEditTabs.get_children():
#		current_resource = main_edit._save_changes(current_resource)
#
	ResourceSaver.save(current_resource, current_resource.resource_path)
	current_resource_state = ResourceStates.Saved
	#refresh list
	for li in range(keys_local.size()):
		%listEntries.set_item_text(li, data.makeEntryShortName(keys_local[li]))

func new_voicedata(path: String) -> void:
	var resource := DialogicVoicedata.new()
	resource.resource_path = path
	resource.display_name = path.get_file().trim_suffix("."+path.get_extension())
	resource.voiceTimes = [Vector2(0.0, 0.1)]
	resource.voiceNotes = ["First segment. change me"]
	ResourceSaver.save(resource, path)
	editors_manager.edit_resource(resource)

# Called when the node enters the scene tree for the first time.
func _ready():
	#%LoadGlossaryFile.icon = get_theme_icon('Folder', 'EditorIcons')
	%btnDeleteSegment.icon = get_theme_icon('Remove', 'EditorIcons')
	%btnAddSegment.icon = get_theme_icon('Add', 'EditorIcons')
	%EntrySearch.right_icon = get_theme_icon('Search', 'EditorIcons')
	valid_text_regex = RegEx.new()
	valid_text_regex.compile(valid_text_regex_pattern)
#	if not plugin_reference:
#		plugin_reference = find_parent('EditorView').plugin_reference
#		print("looking for EditorView: " + find_parent("EditorView").to_string())
#		print("looking for plugin_ref: " + plugin_reference.to_string())
#
#	#test
#	plugin_reference.get_editor_interface().get_resource_previewer().queue_resource_preview("res://test-project/362403__trouby__door-sound.wav",self, &"_on_preview_recived",0)
	pass

func something_changed(fake_argument = "", fake_arg2 = null) -> void:
	if not loading:
		current_resource_state = ResourceStates.Unsaved
		editors_manager.save_current_resource() #TODO, should this happen?
	refresh_list()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#search for a segment. select first match (text contains) in notes, if any.
func seach_by_notes_first(new_text):
	#print ("seach_by_notes_first")
	#print( "%listEntries.item_count ", %listEntries.item_count)
	var li:int = 0
	while li < %listEntries.item_count:
		#print("seach_by_notes_first - scanning index ", li, " for ", new_text)
		var k = keys_local[li]
		if data.voiceNotes[data.getIndex(k)].contains(new_text) or k.contains(new_text):
			selectEntry(li)
			return
		li += 1
	#if none found, do nothing.
	
#when searching, goes to the next match after selected, wraps around.
func seach_by_notes_next(new_text):
	var li = getSelIndex() + 1
	while li < %listEntries.item_count:
		#print("seach_by_notes_next - scanning index ", li, " for ", new_text)
		var k = keys_local[li]
		if data.voiceNotes[data.getIndex(k)].contains(new_text) or k.contains(new_text):
			selectEntry(li)
			return
		li += 1
	#if none found, run first search, effectively wraps around without looping forever.
	seach_by_notes_first(new_text)

#deletes a segment
func _on_btn_delete_segment_pressed():
	var i = data.getIndex(sel_key)
	
	data.voiceTimes.remove_at(i)
	data.voiceNotes.remove_at(i)
	data.voiceKeys.remove_at(i)
	reload_list()

#adds a segment
func _on_btn_add_segment_pressed():
	#generate key name
	var ki = 0
	while str(ki) in data.voiceKeys:
		ki += 1
	var key:String = str(ki)
	#creating data
	data.voiceTimes.append(Vector2(0.0,0.1))
	data.voiceNotes.append("New voice segment")
	data.voiceKeys.append(key)
	
	#adding to list in editor
	%listEntries.add_item(data.makeEntryShortName(key))
	keys_local.append(key)
	selectEntryKey(key)

func _on_rename_key(new_key):
	var i = data.getIndex(sel_key)
	var li = getSelIndex()
	data.voiceKeys[i] = new_key
	#keys_local[li] = new_key
	sel_key = new_key
	refresh_list()
	something_changed()

func _on_notes_changed():
	if loading:
		return
	data.voiceNotes[data.getIndex(sel_key)] = %txtNotes.text
	something_changed()
	
func _on_stop_time_changed(value:float):
	if loading:
		return
	data.voiceTimes[data.getIndex(sel_key)].y = value
	timeline.selectedmarker.y = value
	
	something_changed()

func _on_start_time_changed(value:float):
	if loading:
		return
	%spinStopTime.min_value = max(0.1, %spinStartTime.value+0.1) #Stoptime must start after starttime
	data.voiceTimes[data.getIndex(sel_key)].x = value
	timeline.selectedmarker.x = value
	something_changed()

func _on_btn_test_pressed():
	var li = getSelIndex()
	var key = keys_local[li]
	if key.is_empty():
		return
	if not audio:
		print("Please uh please load an audiofile before trying to play it")
		return
	var start = data.getVoiceStart(key)
	var stop  = data.getVoiceStop(key)
	if start < 0 or stop < 0:
		printerr("Cannot test-play. voice audio segment not found.")
		return
	timeline.play(start, stop)

#key entry text changed.
func _on_entry_key_text_changed(new_text):
	var c = %entryKey.caret_column #Location of the caret, or "text cursor"
	#make sure the name is valid. Only upper-case base english alpha-numerics. No space or special characters.
	new_text = new_text.to_upper() #converts to upper case
	if valid_text_regex.search(new_text): #seraches for other illigal characters
		new_text = valid_text_regex.sub(new_text, "", true) #removes illigal characters
	if %entryKey.text != new_text: #if changes are needed
		c += new_text.length() - %entryKey.text.length() #move caret if neccesary
		%entryKey.text = new_text
		%entryKey.caret_column = c

#key name change requested.
func _on_entry_key_text_submitted(new_text):
	if new_text.length() < 1:
		return
	_on_entry_key_text_changed(new_text) #make sure text is valid.
	var new_key = %entryKey.text
	if (new_key in data.voiceKeys):
		%entryKey.text = sel_key
		return
	#do the change
	_on_rename_key(new_key)
	
func _on_load_audio(_p_name, value):
	data.main_audio_path = value
	audio = load(value)
	if(audio):
		timeline.set_stream(audio, PackedByteArray())
	something_changed()
	
func _on_resource_unsaved():
	if current_resource:
		current_resource.set_meta("timeline_not_saved", true)
func _on_resource_saved():
	if current_resource:
		current_resource.set_meta("timeline_not_saved", false)
