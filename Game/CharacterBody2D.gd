extends CharacterBody2D

var speed: float = 100.
var jump:  float = 100.
var g:     float = 1.


func _ready():
	print(speed)
	print(jump)
	print(g)


func _process(delta):
	velocity.x = Input.get_axis("ui_left", "ui_right") * speed
	if is_on_floor():
		if Input.is_action_just_pressed("ui_select"):
			velocity.y = -jump
	else:
		velocity.y += g
	move_and_slide()
