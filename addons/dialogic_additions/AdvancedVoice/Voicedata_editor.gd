@tool
extends DialogicEditor

var plugin_reference:EditorPlugin
var loading:bool #safety flag, prevents accidental saving
var segmentPanelNode:PackedScene = preload("res://addons/dialogic_additions/AdvancedVoice/VoiceSegmentPanel.tscn")
var audio:AudioStream
var audio_previews:Array[Texture2D]

#data refrences current_resource, but with a Voicedata type-hint
var data:Voicedata 
var sel_entry:int = 0

###TODO: attempt to recreate a preview generator by adding a muted audiobus, and recording it's local volume.


##############################################################################
##							RESOURCE LOGIC
##############################################################################

# Method is called once editors manager is ready to accept registers.
func _register() -> void:
	# Makes the editor open this when a .dch file is selected.
	# Then _open_resource() is called.
	editors_manager.register_resource_editor("dvd", self)
	# Add an "add character" button
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
	current_resource = (resource as Voicedata)
	data = current_resource
	
	# make sure changes in the ui won't trigger saving
	loading = true
	reload_segments()
	
	#maybe todo: add support for multible audiostreams
	#plugin_reference.get_editor_interface().get_resource_previewer().queue_resource_preview(current_resource.get_stream_path(0),self, &"_on_preview_recived",0)
	
	
	
	#(...)
	#Add signal?
	#voicedata_loaded.emit(resource.resource_path)
	loading = false

	#maybe todo: add support for multible audiostreams
func _on_preview_recived(_path:String, preview:Texture2D, _thumbnail_preview:Texture2D, _userdata):
	audio_previews[0] = preview
	%timeline_texture.texture = preview

#func on_move_segment(old_i, new_i):
#	%boxSegments.move_child(%boxSegments.get_child(old_i), new_i)
#	#Segments must be reloaded to refrect their new data
#	reload_segments()
#	something_changed()

#func on_new_segment():
#	var c = segmentPanelNode.instantiate()
#	%boxSegments.add_child(c)
#	something_changed()

#updates the datafields for all the segment panels.
#load_segment grabs the desired data using the child index under %boxSegments
func reload_segments():
	%listEntries.clear()
	var data:Voicedata = current_resource as Voicedata
	for i in range(data.startTimes.size()):
		%listEntries.add_item(data.makeEntryShortName(i))
	if sel_entry < data.startTimes.size():
		selectEntry(sel_entry)
	else:
		selectEntry(0)
#	#if there are too many segment panels, remove the excess
#	#this may happen during loading or when removing a segment
#	while %boxSegments.get_child_count() > l:
#		var c = %boxSegments.get_child(-1)
#		%boxSegments.remove_child(c)
#		c.queue_free()
#	#If there are too few segment panels, add new ones.
#	#This may happen during loading, or when adding a segment
#	while %boxSegments.get_child_count() < l:
#		var c = segmentPanelNode.instantiate()
#		%boxSegments.add_child(c)
#	#update each segment panel
#	for c in %boxSegments.get_children():
#		c.load_segment(current_resource as Voicedata)
func selectEntry(index:int):
	if index < 0 or index >= data.startTimes.size():
		disable_entry_edit()
		return
	loading = true
	sel_entry = index
	%spinIndex.value = sel_entry
	%spinIndex.editable = true
	%spinStartTime.value = data.startTimes[sel_entry]
	%spinStartTime.editable = true
	%spinStopTime.value = data.stopTimes[sel_entry]
	%spinStopTime.editable = true
	%txtNotes.text = data.notes[sel_entry]
	%txtNotes.editable = true
	if not %listEntries.is_selected(sel_entry):
		%listEntries.select(sel_entry, true)
	loading = false
func disable_entry_edit():
	sel_entry = 0
	loading = true
	%spinIndex.value = 0
	%spinIndex.editable = false
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

func new_voicedata(path: String) -> void:
	var resource := Voicedata.new()
	resource.resource_path = path
	resource.display_name = path.get_file().trim_suffix("."+path.get_extension())
	resource.startTimes = [0.0]
	resource.stopTimes = [0.1]
	resource.notes = ["First segment. change me"]
	ResourceSaver.save(resource, path)
	editors_manager.edit_resource(resource)

# Called when the node enters the scene tree for the first time.
func _ready():
	#%LoadGlossaryFile.icon = get_theme_icon('Folder', 'EditorIcons')
	%btnDeleteSegment.icon = get_theme_icon('Remove', 'EditorIcons')
	%btnAddSegment.icon = get_theme_icon('Add', 'EditorIcons')
	%EntrySearch.right_icon = get_theme_icon('Search', 'EditorIcons')
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#search for a segment. select first match (text contains) in notes, if any.
func seach_by_notes_first(new_text):
	var i:int = 0
	while i < data.notes.size():
		if data.notes[i].contains(new_text):
			selectEntry(i)
			return
		i += 1
	#if none found, do nothing.
	
#when searching, goes to the next match after selected, wraps around.
func seach_by_notes_next(new_text):
	var i:int = sel_entry+1
	while i < data.notes.size():
		if data.notes[i].contains(new_text):
			selectEntry(i)
			return
		i += 1
	#if none found, run first search, effectively wraps around without looping forever.
	seach_by_notes_first(new_text)

#deletes a segment
func _on_btn_delete_segment_pressed():
	data.startTimes.remove_at(sel_entry)
	data.stopTimes.remove_at(sel_entry)
	data.notes.remove_at(sel_entry)
	%listEntries.remove_item(sel_entry)
	#after delete
	var s:int = data.startTimes.size()
	if s < 1:
		#TODO: disable entry edit
		disable_entry_edit()
		return
	selectEntry(posmod(sel_entry, data.startTimes.size()))

#adds a segment
func _on_btn_add_segment_pressed():
	data.startTimes.append(0.0)
	data.stopTimes.append(0.1)
	data.notes.append("New voice segment")
	selectEntry(data.startTimes.size()-1)


func _on_notes_changed():
	if loading:
		return
	data.notes[sel_entry] = %txtNotes.text
	something_changed()
	
func _on_stop_time_changed(value:float):
	if loading:
		return
	data.stopTimes[sel_entry] = value
	something_changed()

func _on_start_time_changed(value:float):
	if loading:
		return
	data.startTimes[sel_entry] = value
	something_changed()

#moves a voice segment. 
func _on_index_changed(value:float):
	var s:int = data.startTimes.size()
	if s < 1: #contingency for no data. 
		return
	var v = posmod(int(value), s)
	if loading or v == sel_entry:
		return
	%listEntries.move_item(sel_entry, v)
	#rename entries
	var i = min(sel_entry, v)
	while(i < %listEntries.item_count):
		%listEntries.set_item_text(i, (data.makeEntryShortName(i)))
		i+=1
	#update selected
	sel_entry = v
	something_changed()


