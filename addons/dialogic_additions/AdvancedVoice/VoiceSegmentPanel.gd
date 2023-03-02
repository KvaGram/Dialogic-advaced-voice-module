extends HBoxContainer

var _expanded:bool = false

var _notes:String = ""
var _start:float = 0
var _stop:float = 0

signal index_changed(old_i:int, new_i:int)
signal test_segment(start:float, end:float)

# Called when the node enters the scene tree for the first time.
func _ready():
	%btnExpand.icon = get_theme_icon("Tools", "EditorIcons")
	set_expanded(_expanded)
	%btnExpand.toggled.connect(set_expanded)
	#%btnExpand.pressed.connect(toggle_expand)
	refresh()

func refresh():
	%spinIndex.value = self.get_index()

func toggle_expand():
	set_expanded(!_expanded)
func get_expanded()->bool:
	return _expanded
func set_expanded(val:bool):
	_expanded = val
	%boxNotes.visible = _expanded
func set_notes(val:String):
	%txtNotes.text = val
	_notes = val
	self.tooltip_text = _notes
func get_notes()-> String:
	return _notes
func get_start()->float:
	return _start
func get_stop()->float:
	return _stop
func set_start(val:float):
	%spinStartTime.value = val
	_start = val
	%spinStopTime.min_value = val + 0.1 #stop time must always be greater than start time
func set_stop(val:float):
	%spinStopTime.value = val
	_stop = val

func load_segment(data:Voicedata):
	set_start(data.get_start(self.get_index()))
	set_stop(data.get_stop(self.get_index()))
	set_notes(data.get_notes(self.get_index()))
	refresh()

func sava_segment(data:Voicedata):
	data.startTimes[self.get_index()] = get_start()
	data.stopTimes[self.get_index()] = get_stop()
	data.notes[self.get_index()] = get_notes()
	
	return {
		"start" : get_start(),
		"notes" : get_notes(),
		"stop" : get_stop(),
	}

func _on_txt_notes_text_changed():
	_notes = %txtNotes.text
	self.tooltip_text = _notes

func _on_btn_test_pressed():
	emit_signal("test_segment", get_start(), get_end())

func _on_spin_index_value_changed(value):
	if(int(value) != self.get_index()):
		emit_signal("index_changed", self.get_index(), int(value))


func _on_spin_start_time_value_changed(value):
	_start = value

func _on_spin_stop_time_value_changed(value):
	_stop = value
