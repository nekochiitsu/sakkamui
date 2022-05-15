extends AnimatedSprite
var wait = true

func _process(delta):
	if frame == 7:
		playing = false
	if Input.is_mouse_button_pressed(2): 
		if wait:
			print("uwu")
			position = get_global_mouse_position()
			frame = 0
			playing = true
			wait = false
	else:
		wait = true
func _ready():
	pass
