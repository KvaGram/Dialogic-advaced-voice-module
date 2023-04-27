@tool
extends MarginContainer
class_name VoiceDataTimeline
#how many secunds per pixel
var testbus:int
var drawing:bool = false
var image:Image
var _lastT:float #last timestamp
var _targetT:float
var _secunds_per_pixel:float

var _previewdata:PackedByteArray

var startT:int = 0 # beginning of the visible timeline, in decisecunds
var pageT:int = 200 #how much of the timeline is shown on screen

var editmarker:Vector2 = Vector2.ZERO
var selectedmarker:Vector2 = Vector2.ZERO

var doRedraw:bool = false
var redraw_timer:float = 0
var redraw_time:float = 0.5#minumum wait between drawing the timeline

@onready var scrollTime:HScrollBar = %scrollTime
@onready var drawlayer:Control = %drawlayer
@onready var timeline:TextureRect = %timeline_texture

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#	var image = Image.create(200, 200, false, Image.FORMAT_L8)
#	image.fill(Color.BLACK)
#	%timeline_texture.texture = ImageTexture.create_from_image(image)

#func test():
#	draw_placeholder(%player.stream.get_length(), 1000)
#	#drawing = true
#	play(0, 20)

func _onDrawTimeline():
	var width:int = %boxTimeline.get_rect().size.x
	timeline.draw_rect(Rect2(0, 0, width, 200), Color.DARK_GRAY, true)
	if(width >= pageT):
		_onDrawTimelineWide(float(width) / pageT)
	else:
		_onDrawTimelineThin(float(pageT) / width)
	return

func _onDrawTimelineWide(ppds:float):
	var x:float = 0
	var l:int = 0
	var r:int = 0
	var t:int = startT
	var p_l:int = 0
	var p_r:int = 0
	while t < getStopT():
		#left chennel is stored in even indecies
		l = _previewdata[t*2]
		#right chanel is stored in odd.
		r = _previewdata[(t*2)+1]
		timeline.draw_rect(Rect2(floori(x), 100-l, ceili(ppds), l), Color.ALICE_BLUE, true)
		timeline.draw_rect(Rect2(floori(x), 100, ceili(ppds), r), Color.ALICE_BLUE, true)
		x += ppds 
		t += 1
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
	#Hard-testing start as 2 secunds, stop as 5 secunds, play at 2.5 secunds
	
	#test, do remove.
	#drawlayer.draw_circle(Vector2(20, 20), 10, Color.YELLOW)
	
	#TODO: convert from datapoint to local pixel x-co-ordinate
	
#	var start = (-startT + 20) * scale
#	var stop = (-startT + 50) * scale
	
	#print("drawing makers at start %d stop %d play %d" % [start, stop, play])
#	drawlayer.draw_line(Vector2(start, 0), Vector2(start, 50), Color.BLUE, 2, true)
#	drawlayer.draw_line(Vector2(stop, 0), Vector2(stop, 50), Color.DARK_RED, 2, true)
#	drawlayer.draw_line(Vector2(play, 200), Vector2(play, 50), Color.DARK_GREEN, 2, true)
	
	
	#TODO - sedocode below
	
	#first test if start and/or stop is out of range. If so, do special case for that.
	
	#PageT / MaxT gets scale (?). multiply by pixel width.
	#startT * scale gets offset.
	#draw yellow horizontal line between start and stop
	#draw vertical lines: blue for start, red for stop. If playing, also draw green line for current play posision.

# Called every frame. 'delta' is the elapsed time since the previous frame.
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
#		if redraw_timer >= redraw_time:
#			draw_preview()
#		else:
#			redraw_timer += delta
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
	

#Draw the preview.
#Will draw wide if there are more pixel width than datapoints (stero decisecunds)
#will draw thin if there are more datapoints than pixel width
func draw_preview():
	#test override
	timeline.queue_redraw()
	
	redraw_timer = 0
	doRedraw = false
	return
	
	var width:int = %boxTimeline.get_rect().size.x
	if width < 0:
		printerr("VoiceDataTimeline has no space to draw")
		return
	if pageT < 0:
		#woops. Something went wrong. Quick! Draw a placeholder, pretend everything is alright! (even though we know it's not D>:} )
		Image.create(width, 200, false, Image.FORMAT_L8)
		image.fill(Color.GRAY)
		%timeline_texture.texture = ImageTexture.create_from_image(image)
		return
	if(width >= pageT):
		_draw_preview_wide(float(width) / pageT)
	else:
		_draw_preview_thin((float(pageT) / width))
	return

#draw wide. Takes in ppds, pixels per decisecunds, to know how many pixels wide to draw for each datapoint.
#ppds pixels per decisecunds, rounded to whole
func _draw_preview_wide(ppds:float):
	#exact width of the texture is adjusted to allow for any rounding of ppds
	#resulting texture width may not fit perfectly in timeline_texture, so this element is set to scale the resulting texture.
	var width:int = ceili(ppds * (pageT))
	#print("Drawing wide preview with ppds: ", ppds)
	##image is limited to a grayscale format, with black as silence, and white as volume/data.
	var image = Image.create(width, 200, false, Image.FORMAT_L8)
	image.fill(Color.BLACK)
	
	#The time t posision controls what to draw in the drawing-loop, x is incremented by ppds
	var x:float = 0
	var t:int = startT
	var l:int = 0
	var r:int = 0
	while t < getStopT():
		#left chennel is stored in even indecies
		l = _previewdata[t*2]
		#right chanel is stored in odd.
		r = _previewdata[(t*2)+1]
		#left channel is drawn in negative Y, right in positive Y
		image.fill_rect(Rect2i(floori(x), 100-l, ceili(ppds), l), Color.WHITE)
		image.fill_rect(Rect2i(floori(x), 100, ceili(ppds), r), Color.WHITE)
		x += ppds 
		t += 1
	%timeline_texture.texture = ImageTexture.create_from_image(image)
		

#draws thin. Takes in dspp decisecundsper pixel, to know how many datapoints makes up one pixel.
#dspp decisecunds per pixel, rounded to whole
func _draw_preview_thin(dspp):
	#exact width of the texture is adjusted to allow for any rounding of dspp
	#resulting texture width may not fit perfectly in timeline_texture, so this element is set to scale the resulting texture.
	var width:int = ceili((getStopT() - startT)/dspp)
	#image is limited to a grayscale format, with black as silence, and white as volume/data.
	var image = Image.create(width, 200, false, Image.FORMAT_L8)
	image.fill(Color.BLACK)
	
	#the x posision decides what to draw in the drawing-loop, t is incremented by dspp as values inbetween are averaged.
	var x:int = 0
	var t:int = startT
	var l:int = 0
	var r:int = 0
	var t_t:int = 0
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
		image.fill_rect(Rect2i(x, 100-l, 1, l), Color.WHITE)
		image.fill_rect(Rect2i(x, 100, 1, r), Color.WHITE)
		x += 1
	%timeline_texture.texture = ImageTexture.create_from_image(image)

		
func _on_audio_stop():
	pass
#	drawing = false
#	%timeline_texture.texture = ImageTexture.create_from_image(image)
#func refreshScale():
#	var s = base_scale * pow(2, scale_value)
#	print("refreshing scale. Base is %s, value is %s. 2 pow(scale_value) = %s, resulting scale: %s"%[base_scale, scale_value, pow(2, scale_value), s])
#	%timeline_texture.scale = Vector2(s, 1)
#


#func changeScale(change):
#	setScale(scale_value + change)
	
#func setScale(value):
#	var c = startT + (getStopT()-startT)/2
#	scale_value = clamp(value, 0, 10)
#	var l_max = %player.stream.get_length() * 10
#	var l = ceili(l_max / pow(2, scale_value))
#	startT = c - l/2
#	getStopT() = startT + l
#	if startT < 0:
#		getStopT() -= startT
#		startT -= startT
#	elif getStopT() > l_max:
#		startT -= (getStopT() - l_max)
#		getStopT() -= (getStopT() - l_max)
#	startT = max(startT, 0)
#	getStopT() = min(getStopT(), l_max)
#	draw_preview()

func getMaxT() -> int:
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
