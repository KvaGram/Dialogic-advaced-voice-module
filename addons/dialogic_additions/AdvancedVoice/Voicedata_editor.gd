@tool
extends DialogicEditor

var loading:bool #safety flag, prevents accidental saving

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
			'*.dch; DialogicCharacter',
			'Create new character',
			'character',
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

func _save_resource() -> void:
	if ! visible or not current_resource:
		return
	
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
#	ResourceSaver.save(current_resource, current_resource.resource_path)
#	current_resource_state = ResourceStates.Saved
#	editors_manager.resource_helper.rebuild_character_directory()

func new_voicedata(path: String) -> void:
	var resource := Voicedata.new()
	resource.resource_path = path
	resource.display_name = path.get_file().trim_suffix("."+path.get_extension())
	#example code from character editor. Mimic and adapt for voicedata.	
#	resource.color = Color(1,1,1,1)
#	resource.default_portrait = ""
#	resource.custom_info = {}
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
