@tool
extends MarginContainer
#how many secunds per pixel
var testbus:int
var drawing:bool = false
var image:Image
var _lastT:float #last timestamp
var _secunds_per_pixel:float
var stopT:float

var base_scale:float #scale to fit whole timeline image in editor window
var scale_value:int #indicates viewscale in a power of 2. Where values 0, 1, 2, 3 is x1, x2, x4, x8 etc.
var focusX:float #
# Called when the node enters the scene tree for the first time.
func _ready():
	draw_placeholder(100, 400)

func test():
	draw_placeholder(%player.stream.get_length(), 1000)
	#drawing = true
	play(0, 20)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (%player.playing):
		var l:int = int( 100 * db_to_linear(AudioServer.get_bus_peak_volume_left_db(0,0)))
		var r:int = int( 100 * db_to_linear(AudioServer.get_bus_peak_volume_right_db(0,0)))
		var p = %player.get_playback_position()
		#print("%s - %s"%[p, p * _secunds_per_pixel])
		var length:int = max(1, (p - _lastT) * _secunds_per_pixel)
		var xpos:int = int(_lastT * _secunds_per_pixel)
		image.fill_rect(Rect2i(xpos, 0, length, 200), Color.BLACK)
		image.fill_rect(Rect2i(xpos, 100-l, length, l), Color.WHITE)
		image.fill_rect(Rect2i(xpos, 100, length, r), Color.WHITE)
		_lastT = p
		%timeline_texture.texture = ImageTexture.create_from_image(image)
		if p > stopT:
			%player.stop()

func set_stream(stream:AudioStream):
	%player.stream = stream
	draw_placeholder(stream.get_length(), get_rect().size.x)

func play(start:float, stop:float):
	_lastT = start
	stopT = stop
	%player.play(start)


#TODO experiment with other ways of determining pixel width Maybe 16x pixel width
# draws a placeholder graphic for a length secunds of audio. one dot every 10 secunds
func draw_placeholder(time_length:float, pixel_width:int):
	#create image with 8-bit grayscale format
	_secunds_per_pixel = pixel_width / time_length
	print(_secunds_per_pixel)
	var stepsize = 1
	while stepsize * _secunds_per_pixel < 10:
		stepsize = stepsize * 60
	print("creating image sized %s"%[pixel_width])
	image = Image.create(int(pixel_width), 200, false, Image.FORMAT_L8)
	image.fill(Color.BLACK)
	var step:int = round(stepsize*_secunds_per_pixel)
	var p:int = step
	while p < pixel_width:
		image.fill_rect(Rect2i(p-5,95,10,10),Color.WHITE)
		p+=step
		%timeline_texture.texture = ImageTexture.create_from_image(image)
		#print("pixel = %s"%[p])
	var rectx = %boxTimeline.get_rect().size.x
	if rectx <=0:
		base_scale = 1
	else:
		base_scale = rectx / pixel_width
		print("base_scale = %%boxTimeline.get_rect().size.x / pixel_width = %s / %s = %s"%[%boxTimeline.get_rect().size.x, pixel_width, base_scale])
	scale_value = 0
	refreshScale()
		
func _on_audio_stop():
	drawing = false
	%timeline_texture.texture = ImageTexture.create_from_image(image)
func refreshScale():
	var s = base_scale * pow(2, scale_value)
	print("refreshing scale. Base is %s, value is %s. 2 pow(scale_value) = %s, resulting scale: %s"%[base_scale, scale_value, pow(2, scale_value), s])
	%timeline_texture.scale = Vector2(s, 1)
	


func changeScale(change):
	setScale(scale_value + change)
func setScale(value):
	var old_x = %scrollX.value / %scrollX.max_value
	scale_value = clamp(value, 0, 10)
	%txtScale.text = str(scale_value)
	refreshScale()
	var rectx = %boxTimeline.get_rect().size.x
	var timex = %timeline_texture.get_rect().size.x
	var space = maxi(timex - rectx, 0)
	print("timeline X ", timex, "rect X ", rectx, "space ", space)
	%scrollX.max_value = space
	%scrollX.value = old_x*space
	setTimelineScroll(%scrollX.value)
	
func setTimelineScroll(value):
	%timeline_texture.position.x = -value
