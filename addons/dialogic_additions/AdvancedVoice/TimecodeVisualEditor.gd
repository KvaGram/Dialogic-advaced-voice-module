extends DialogicVisualEditorField
var time:float #time in secunds
enum DisplayMode {TIMECODE, PLAIN}
var mode:DisplayMode = DisplayMode.TIMECODE
var regex_plain:RegEx
var regex_timecode:RegEx

func _ready():
	regex_plain = RegEx.new()
	regex_plain.compile('[^0-9.]')
	regex_timecode = RegEx.new()
	regex_timecode.compile("[^0-9.:]")

## To be overwritten
func _load_display_info(info:Dictionary) -> void:
	if info.has('label'):
		$Label.visible = true
		$Label.text = String(info['label'])
	else:
		$Label.visible = false


## To be overwritten
func _set_value(value:Variant) -> void:
	time = float(value)
	refresh()

func refresh():
	var caret = $text.caret_column
	var t = secundsToTimecode(time)
	if mode == DisplayMode.PLAIN:
		$text.text = "%0.2f" % time
	elif mode == DisplayMode.TIMECODE:
		$text.text = "%2d:%2d:%2d.%2d" % [t.get('h', 0), t.get('m', 0), t.get('s', 0), t.get('cs', 0)]
	$text.caret_column = caret
	$text.tooltip_text = "%s - %2d hour(s), %2d minute(s) and %2d.%2d secund(s)" % [property_name, t.get('h', 0), t.get('m', 0), t.get('s', 0), t.get('cs', 0)]




func _on_mode_toggled(plainmode:bool):
	if plainmode:
		mode = DisplayMode.PLAIN
	else:
		mode = DisplayMode.TIMECODE
	refresh()

func secundsToTimecode(s:float)->Dictionary:
	var ret = {}
	ret['h'] = roundi(time / 3600)
	ret['m'] = roundi(time / 60) % 60
	ret['s'] = roundi(time) % 60
	ret['cs']= roundi(time * 100) % 100
	return ret

func _on_text_text_changed(text:String):
	var re:RegEx = regex_plain if mode==DisplayMode.PLAIN else regex_timecode
	var c = $text.caret_column
	var t:float = 0
	if re.search(text):
		text = re.sub(text, "", true) #remove illigal characters
	if text != $text.text:
		c += text.length() - $text.text.length()
		$text.text = text
		$text.caret_column = c
	if mode == DisplayMode.PLAIN:
		t = float(text)
	elif mode == DisplayMode.TIMECODE:
		var split:PackedStringArray = text.split(":", true, 3) #["hours", "minutes","secunds.centi-secunds"]
		split.reverse()#["secunds.centi-secunds", "minutes", "hours"]
		var split2:PackedStringArray = split[0].split(".", true, 2) #["secunds", "centi-secunds"]
		if len(split) >= 2: #add hours
			t += 3600 * int(split[2])
		if len(split) >= 1: #add minutes
			t += 60 * int(split[1])
		t += int(split2[0])
		if len(split2) >=1:
			t += int(split2[1])/100
	var t2 = secundsToTimecode(t)
	$text.tooltip_text = "%s - %2d hour(s), %2d minute(s) and %2d.%2d secund(s)" % [property_name, t2.get('h', 0), t2.get('m', 0), t2.get('s', 0), t2.get('cs', 0)]
	time = t
	value_changed.emit(property_name, time)
