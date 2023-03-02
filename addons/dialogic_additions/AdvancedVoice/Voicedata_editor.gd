@tool
extends DialogicEditor

var loading:bool #safety flag, prevents accidental saving
var segmentPanelNode:PackedScene = preload("res://addons/dialogic_additions/AdvancedVoice/VoiceSegmentPanel.tscn")

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
	
	# make sure changes in the ui won't trigger saving
	loading = true
	
	
	
	#(...)
	#Add signal?
	#voicedata_loaded.emit(resource.resource_path)
	loading = false

func on_move_segment(old_i, new_i):
	%boxSegments.move_child(%boxSegments.get_child(old_i), new_i)
	#Segments must be reloaded to refrect their new data
	reload_segments()
	something_changed()

#updates the datafields for all the segment panels.
#load_segment grabs the desired data using the child index under %boxSegments
func reload_segments():
	var l = (current_resource as Voicedata).startTimes.size()
	#if there are too many segment panels, remove the excess
	#this may happen during loading or when removing a segment
	while %boxSegments.get_child_count() > l:
		var c = %boxSegments.get_child(-1)
		%boxSegments.remove_child(c)
		c.queue_free()
	#If there are too few segment panels, add new ones.
	#This may happen during loading, or when adding a segment
	while %boxSegments.get_child_count() < l:
		var c = segmentPanelNode.instantiate()
		%boxSegments.add_child(c)
	#update each segment panel
	for c in %boxSegments.get_children():
		c.load_segment(current_resource as Voicedata)

func _save_resource() -> void:
	if ! visible or not current_resource:
		return
	
	for c in %boxSegments.get_children():
		c.save_segment(current_resource)
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
	resource.startTimes[0] = 0.0
	resource.stopTimes[0] = 0.1
	resource.notes[0] = "First segment. change me"
	ResourceSaver.save(resource, path)
	editors_manager.edit_resource(resource)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func something_changed(fake_argument = "", fake_arg2 = null) -> void:
	if not loading:
		current_resource_state = ResourceStates.Unsaved
		editors_manager.save_current_resource() #TODO, should this happen?


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
