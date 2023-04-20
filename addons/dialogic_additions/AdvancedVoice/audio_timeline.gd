@tool
extends MarginContainer
#how many secunds per pixel
var testbus:int
var drawing:bool = false
var image:Image
var _lastT:float #last timestamp
var _secunds_per_pixel:float

var _previewdata:PackedByteArray

var base_scale:float #scale to fit whole timeline image in editor window
var scale_value:int #indicates viewscale in a power of 2. Where values 0, 1, 2, 3 is x1, x2, x4, x8 etc.

var startT:int = 0 # beginning of the visible timeline, in decisecunds
var stopT:int = 200 # end of the visible timeline

var doRedraw:bool = false
var redraw_timer:float = 0
var redraw_time:float = 5

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (%player.playing):
		var l:int = int( 100 * db_to_linear(AudioServer.get_bus_peak_volume_left_db(0,0)))
		var r:int = int( 100 * db_to_linear(AudioServer.get_bus_peak_volume_right_db(0,0)))
		var p:int = floori(%player.get_playback_position() * 10)
		_previewdata[p*2] = l
		_previewdata[(p*2)+1] = r
		
		if p > stopT:
			%player.stop()
	if doRedraw:
		if redraw_timer >= redraw_time:
			draw_preview()
func set_stream(stream:AudioStream, previewdata:PackedByteArray):
	%player.stream = stream
	set_previewdata(previewdata)
	startT = 0
	stopT = floori(stream.get_length() * 10)
	doRedraw = true

func play(start:float, stop:float):
	_lastT = start
	stopT = stop
	%player.play(start)

func get_previewdata()->PackedByteArray:
	return _previewdata.compress()
func set_previewdata(val:PackedByteArray):
	var length = roundi(%player.stream.get_length() * 20) # 2 channels, decisecunds.
	if val.size() == length:
		_previewdata = val
	else:
		_previewdata = val.decompress(length)
		

func draw_preview():
	redraw_timer = 0
	doRedraw = false
	var width:int = %boxTimeline.get_rect().size.x
	var time_width = stopT - startT
	if(width >= time_width):
		_draw_preview_wide(width / time_width)
	else:
		_draw_preview_thin(ceili(float(time_width) / width))
	return
	
#ppds pixels per decisecunds, rounded to whole
func _draw_preview_wide(ppds:int):
	var width:int = ppds * (stopT - startT) #We leave the texture stretching to the engine
	var image = Image.create(width, 200, false, Image.FORMAT_L8)
	image.fill(Color.BLACK)
	
	var x:int = 0
	var t:int = startT
	var l:int = 0
	var r:int = 0
	while t < stopT:
		l = _previewdata[t*2]
		r = _previewdata[(t*2)+1]
		image.fill_rect(Rect2i(x, 0, ppds, 200), Color.BLACK)
		image.fill_rect(Rect2i(x, 100-l, ppds, l), Color.WHITE)
		image.fill_rect(Rect2i(x, 100, ppds, r), Color.WHITE)
		x += ppds
		t += 1
	%timeline_texture.texture = ImageTexture.create_from_image(image)
		
		
#dspp decisecunds per pixel, rounded to whole
func _draw_preview_thin(dspp):
	var width:int = ceili((stopT - startT)/dspp)
	var image = Image.create(width, 200, false, Image.FORMAT_L8)
	image.fill(Color.BLACK)
	var x:int = 0
	var t:int = startT
	var l:int = 0
	var r:int = 0
	var t_t:int = 0
	while x < width:
		l = 0
		r = 0
		t = x * dspp
		t_t = max(stopT, t + dspp)
		while t < t_t:
			l += _previewdata[t*2]
			r += _previewdata[(t*2)+1]
			t += 1
		l = l/dspp
		r = r/dspp
		image.fill_rect(Rect2i(x, 0, 1, 200), Color.BLACK)
		image.fill_rect(Rect2i(x, 100-l, 1, l), Color.WHITE)
		image.fill_rect(Rect2i(x, 100, 1, r), Color.WHITE)
		x += 1
	%timeline_texture.texture = ImageTexture.create_from_image(image)

#TODO experiment with other ways of determining pixel width Maybe 16x pixel width
# draws a placeholder graphic for a length secunds of audio. one dot every 10 secunds
#func draw_placeholder(time_length:float, pixel_width:int):
#	#create image with 8-bit grayscale format
#	_secunds_per_pixel = pixel_width / time_length
#	print(_secunds_per_pixel)
#	var stepsize = 1
#	while stepsize * _secunds_per_pixel < 10:
#		stepsize = stepsize * 60
#	print("creating image sized %s"%[pixel_width])
#	image = Image.create(int(pixel_width), 200, false, Image.FORMAT_L8)
#	image.fill(Color.BLACK)
#	var step:int = round(stepsize*_secunds_per_pixel)
#	var p:int = step
#	while p < pixel_width:
#		image.fill_rect(Rect2i(p-5,95,10,10),Color.WHITE)
#		p+=step
#		%timeline_texture.texture = ImageTexture.create_from_image(image)
#		#print("pixel = %s"%[p])
#	var rectx = %boxTimeline.get_rect().size.x
#	if rectx <=0:
#		base_scale = 1
#	else:
#		base_scale = rectx / pixel_width
#		print("base_scale = %%boxTimeline.get_rect().size.x / pixel_width = %s / %s = %s"%[%boxTimeline.get_rect().size.x, pixel_width, base_scale])
#	scale_value = 0
#	refreshScale()
		
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
#	var c = startT + (stopT-startT)/2
#	scale_value = clamp(value, 0, 10)
#	var l_max = %player.stream.get_length() * 10
#	var l = ceili(l_max / pow(2, scale_value))
#	startT = c - l/2
#	stopT = startT + l
#	if startT < 0:
#		stopT -= startT
#		startT -= startT
#	elif stopT > l_max:
#		startT -= (stopT - l_max)
#		stopT -= (stopT - l_max)
#	startT = max(startT, 0)
#	stopT = min(stopT, l_max)
#	draw_preview()

func setStart(value):
	startT = maxi(value, 0)
	doRedraw = true
func setEnd(value):
	stopT = mini(value, (%player.stream.get_length() * 10))
	doRedraw = true
	
