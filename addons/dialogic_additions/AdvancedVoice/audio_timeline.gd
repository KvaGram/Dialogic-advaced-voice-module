@tool
extends MarginContainer
#how many secunds per pixel
var testbus:int
var drawing:bool = false
var image:Image
var _lastT:float #last timestamp
var _secunds_per_pixel:float

## Called when the node enters the scene tree for the first time.
#func _ready():
#	pass

func test():
	draw_placeholder(%player.stream.get_length(), 1000)
	#drawing = true
	play(0)

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

func play(time:float):
	_lastT = time
	%player.play(time)

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
		
func _on_audio_stop():
	drawing = false
	%timeline_texture.texture = ImageTexture.create_from_image(image)
