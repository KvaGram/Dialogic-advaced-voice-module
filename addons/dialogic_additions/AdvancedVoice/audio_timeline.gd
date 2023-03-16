extends MarginContainer
#how many secunds per pixel


# Called when the node enters the scene tree for the first time.
func _ready():
	draw_placeholder(36000, 1000)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# draws a placeholder graphic for a length secunds of audio. one dot every 10 secunds
func draw_placeholder(time_length:float, pixel_width:int):
	#create image with 8-bit grayscale format
	var secunds_per_pixel = pixel_width / time_length
	var stepsize = 1
	while stepsize * secunds_per_pixel < 10:
		stepsize = stepsize * 60
	print("creating image sized %s"%[pixel_width])
	var img = Image.create(int(pixel_width), 200, false, Image.FORMAT_L8)
	img.fill(Color.BLACK)
	var step:int = round(stepsize*secunds_per_pixel)
	var p:int = step
	while p < pixel_width:
		img.fill_rect(Rect2i(p-5,95,10,10),Color.WHITE)
		p+=step
		#print("pixel = %s"%[p])
	%timeline_texture.texture = ImageTexture.create_from_image(img)
	
