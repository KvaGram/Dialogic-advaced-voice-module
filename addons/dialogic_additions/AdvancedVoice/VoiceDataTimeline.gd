@tool
extends MarginContainer
class_name VoicedataTimeline
var _lastT:float #last timestamp
var _targetT:float

var _previewdata:PackedByteArray

var startT:int = 0 # beginning of the visible timeline, in decisecunds
var pageT:int = 200 #how much of the timeline is shown on screen

var editmarker:Vector2 = Vector2.ZERO
var selectedmarker:Vector2 = Vector2.ZERO

var doRedraw:bool = false

@onready var scrollTime:HScrollBar = %scrollTime
@onready var drawlayer:Control = %drawlayer
@onready var timeline:TextureRect = %timeline_texture

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

#Draw the timeline with an audio preview.
#Will draw wide if there are more pixel width than datapoints (stero decisecunds)
#will draw thin if there are more datapoints than pixel width
func _onDrawTimeline():
	var width:int = %boxTimeline.get_rect().size.x
	timeline.draw_rect(Rect2(0, 0, width, 200), Color.DARK_GRAY, true)
	
	if(width >= pageT):
		_onDrawTimelineWide(float(width) / pageT)
	else:
		_onDrawTimelineThin(float(pageT) / width)
	#draw a thin line to seperate left (top) and right (bottom) channels
	timeline.draw_line(Vector2(0, 100), Vector2(width, 100), Color.DARK_GRAY, 1, true)

func _onDrawTimelineWide(ppds:float):
	if not %player.stream:
		return
	var x:float = 0
	var l:int = 0
	var r:int = 0
	var t:int = startT
	var p_l:int = 0 if startT <= 0 else _previewdata[(t)*2 - 2]
	var p_r:int = 0 if startT <= 0 else _previewdata[(t*2) - 1]
	var shape:PackedVector2Array = PackedVector2Array()
	shape.resize(4)
	while t < getStopT():
		#left chennel is stored in even indecies
		l = _previewdata[t*2]
		#right chanel is stored in odd.
		r = _previewdata[(t*2)+1]
		shape[0] = Vector2(floori(x), 100-p_l)
		shape[1] = Vector2(ceili(x + ppds), 100-l)
		shape[2] = Vector2(ceili(x + ppds), 100+r)
		shape[3] = Vector2(floori(x), 100+p_r)
		timeline.draw_colored_polygon(shape, Color.ALICE_BLUE)
		x += ppds 
		t += 1
		p_l = l
		p_r = r
func _onDrawTimelineThin(dspp:float):
	var x:int = 0
	var t:int = startT
	var l:int = 0
	var r:int = 0
	var t_t:int = 0
	var width:int = %boxTimeline.get_rect().size.x
	while x < width:
		l = 0
		r = 0
		t = x * dspp
		t_t = max(getStopT(), t + dspp)
		while t < t_t:
			#left chennel is stored in even indecies
			l += _previewdata[t*2]
			#right chanel is stored in odd.
			r += _previewdata[(t*2)+1]
			t += 1
		l = l/dspp
		r = r/dspp
		#left channel is drawn in negative Y, right in positive Y
		timeline.draw_rect(Rect2i(x, 100-l, 1, l), Color.ALICE_BLUE, true)
		timeline.draw_rect(Rect2i(x, 100, 1, r), Color.ALICE_BLUE, true)
		x += 1

func _onDrawmarkers():
	var x:float
	var y:float
	var s:float = %boxTimeline.get_rect().size.x / pageT
	#draw selected marker

	if(selectedmarker.y - selectedmarker.x > 0.1):
		x = (selectedmarker.x*10 - startT) * s #start of selected
		y = (selectedmarker.y*10 - startT) * s #stop of selected
		#print("selectedmarker.x ", selectedmarker.y)
		drawlayer.draw_line(Vector2(x, 150), Vector2(x, 200), Color.CYAN, 2, true)
		drawlayer.draw_line(Vector2(y, 150), Vector2(y, 200), Color.RED, 2, true)
		drawlayer.draw_line(Vector2(x, 200), Vector2(y, 200), Color.ORANGE, 2, true)
#	if(editmarker.y - editmarker.x > 0.1):
#		x = (editmarker.x*10 - startT) * s #start of edit
#		y = (editmarker.y*10 - startT) * s #stop of edit	
#		drawlayer.draw_line(Vector2(x, 0), Vector2(x, 20), Color.BLUE, 2, true)
#		drawlayer.draw_line(Vector2(x, 30), Vector2(x, 50), Color.BLUE, 2, true)
#		drawlayer.draw_line(Vector2(y, 0), Vector2(y, 20), Color.DARK_RED, 2, true)
#		drawlayer.draw_line(Vector2(y, 30), Vector2(y, 50), Color.DARK_RED, 2, true)
#		drawlayer.draw_line(Vector2(x, 0), Vector2(y, 0), Color.YELLOW, 2, true)
	
	if (%player.playing):
		x = (%player.get_playback_position() * 10 - startT) * s
		drawlayer.draw_line(Vector2(x, 150), Vector2(x, 50), Color.DARK_GREEN, 2, true)

func _process(delta):
	#always redraw markers
	drawlayer.queue_redraw()
	if (%player.playing):
		#saving volume of left and right channels.
		#value is set to minimum of 1, so no data (value 0) can be seperated from silence
		var l:int = maxi(1, 100 * db_to_linear(AudioServer.get_bus_peak_volume_left_db(0,0)))
		var r:int = maxi(1, 100 * db_to_linear(AudioServer.get_bus_peak_volume_right_db(0,0)))
		var p:int = floori(%player.get_playback_position() * 10)
		_previewdata[p*2] = l
		_previewdata[(p*2)+1] = r
		doRedraw = true
		
		if %player.get_playback_position() > _targetT:
			%player.stop()
	if doRedraw:
		timeline.queue_redraw()
		doRedraw = false
func set_stream(stream:AudioStream, previewdata:PackedByteArray):
	#TODO warn user if clip length is less than 1 secund.
	%player.stream = stream
	set_previewdata(previewdata)
	setStartPage(0, getMaxT())

func play(start:float, stop:float):
	_lastT = start
	_targetT = stop
	%player.play(start)

func get_previewdata()->PackedByteArray:
	return _previewdata.compress()
func set_previewdata(val:PackedByteArray):
	var length = ceili(%player.stream.get_length() * 20) # 2 channels, decisecunds.
	#if incoming data is empty, make a new packedbytearray
	if val.size() < 1:
		_previewdata = PackedByteArray()
		_previewdata.resize(length)
		return
	#if length is a match, go ahead and set it.
	if val.size() == length:
		_previewdata = val
		return
	#finally, presume the data is compressed, trust the decompress function to know what to do.
	_previewdata = val.decompress(length)
	#It does not matter if the preview is lost or wrong. It will set again during test playback.
	
#draws thin. Takes in dspp decisecundsper pixel, to know how many datapoints makes up one pixel.
#dspp decisecunds per pixel, rounded to whole

func _on_audio_stop():
	pass

func getMaxT() -> int:
	if not %player.stream:
		return 1
	return int(%player.stream.get_length() * 10)
func getStopT() -> int:
	return min(startT + pageT, getMaxT())
func getStartT() -> int:
	return startT
func getPageT() -> int:
	return pageT

func setStartPage(start:int, page:int):
	pageT = clampi(page, 1, getMaxT())
	startT = clampi(start, 0, getMaxT() - pageT)
	
	scrollTime.page = pageT
	scrollTime.value = startT
	scrollTime.max_value = getMaxT()
	doRedraw = true

func setStart(value):
	startT = maxi(value, 0)
	doRedraw = true

func setPagesize(value:int):
	#clamping page size to minimum of 10 decisecunds
	#minor concerns in edgecase where user loads clip lasting less than 1 secund. why? mistake? some hack parhaps? 
	value = clamp(value, 10, getMaxT()) 
	var diff = value - pageT
	setStartPage(max(startT - diff/2, 0), value)

func _on_btn_minus_pressed():
	setPagesize(pageT * 2)

func _on_btn_plus_pressed():
	setPagesize(pageT / 2)


func _on_scroll_time_value_changed(value):
	setStart(int(value))
