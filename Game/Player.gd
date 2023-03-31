extends CharacterBody2D

# Parts:
# Select -> /part/ <- and press CTRL+D to jump on the next one !
# /process/
# /online/

var target_position: Vector2 = position
var speed:             float = 100.
# === Online ===
var online:                             Dictionary = { # Interpolated variables automatically assigned with online_interpolated_process()
	"delay": 0., 
	"interpolated":
	{
		"position": position, 
		"rotation": rotation
	}, 
	"events":
	{
		# "function_name": [call_time = 0., call_arguments = []], 
		"remoted_print": [0., []]
	}
}
var last_online_events:                 Dictionary = {}
var last_online_interpolated_variables: Dictionary = {}
# ===

# Select -> /part/ <- and press CTRL+D to jump on the next one !
# /process/


func _ready() -> void:
	for variable_name in online["interpolated"]:
		last_online_interpolated_variables[variable_name] = online["interpolated"][variable_name]
	if Network.is_master(self):
		var Camera: Camera2D = Camera2D.new()
		Camera.name = "Camera"
		Camera.position_smoothing_enabled = true
		add_child(Camera)
		Camera.make_current()
		for _i in range(5):
			add_child(load("res://Game/Player_Light.tscn").instantiate())


func _process(delta: float) -> void:
	if Network.is_master(self):
		look_at(get_global_mouse_position())
		if Input.is_action_pressed("move"):
			rcp_change_target_position(get_global_mouse_position())
		move(delta)
	else:
		online_interpolated_process()


func _physics_process(_delta: float) -> void:
	if Network.is_master(self):
		online["interpolated"]["position"] = position
		online["interpolated"]["rotation"] = position
	else:
		remoted_function_execution()


func move(delta: float) -> void:
	speed = 500
	var relative_target_position: Vector2 = (target_position - position)
	var current_speed: float = speed
	if relative_target_position.length() * (1 / delta) < current_speed:
		current_speed = relative_target_position.length() * (1 / delta)
	velocity = relative_target_position.normalized() * current_speed
	move_and_slide()


func rcp_change_target_position(target: Vector2) -> void:
	if Network.is_master(self):
		online["events"]["rcp_change_target_position"] = [Tools.time, [target]]
	target_position = target


# Select -> /part/ <- and press CTRL+D to jump on the next one !
# /online/


# WARNING: IF AN FUNCTION IS EXECUTED MORE THAN ONE TIME BETWEEN 2 NETWORK UPDATE IT WILL BE IGNORED
# SO IF YOU TAKE 1 SECOND TO RECIVE THE EXECUTED FUNCTIONS:
# online["delay"] + (Network.Getter.request_delay / 2) = 1 # NOT EXACT
# AND THE MASTER OF THE NODE EXECUTE A FUNCTION 2 TIMES PER SECOND YOU WILL ONLY RECEVE ONE OF THE
# TWO CALLS (THE LAST)
func remoted_function_execution() -> void:
	for event in online["events"].keys():
		if !(event in last_online_events.keys()):
			last_online_events[event] = 0
		if online["events"][event][0] != last_online_events[event]:
			last_online_events[event] = online["events"][event][0]
			if online["events"][event][1] is Array:
				if has_method(event):
					callv(event, online["events"][event][1])
				else:
					print("ERROR: Method ", event, "() not found on ", get_path())


func online_interpolated_process() -> void:
	var delay = online["delay"] + (Network.Getter.request_delay / 2)
	var interpolation = clamp((Tools.time - Network.Getter.request_time) / delay, 0, 1)
	for key in online["interpolated"].keys():
		set(key, 
			(1 - interpolation) * last_online_interpolated_variables[key] + 
			interpolation       * online["interpolated"][key]
		)
