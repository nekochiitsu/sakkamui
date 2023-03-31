extends HTTPRequest

# Parts:
# Select -> /part/ <- and press CTRL+D to jump on the next one !
# /process/
# /automatic_data_tools/
# /request_functions/
# /automatic_request_calling/

var type:                     int = 0

var pass_request_action: Callable = func ignore(): pass
var request_action:      Callable = pass_request_action

var request_time:           float = 0.
var request_delay:          float = 0.

# Select -> /part/ <- and press CTRL+D to jump on the next one !
# /process/


func _ready():
	connect("request_completed", _request_completed)
	use_threads = true
	timeout = 10


func _physics_process(_delta):
	if Network.is_processing \
			and get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
		if type == Network.TYPE_SYNCHONIZER:
			online_sync()
		elif type == Network.TYPE_GETTER:
			online_get()
		elif type == Network.TYPE_SETTER:
			online_set()


# Select -> /part/ <- and press CTRL+D to jump on the next one !
# /automatic_data_tools/


func convert_vectors(data):
	var values
	var keys
	if data is Dictionary:
		keys = data.keys()
		values = data.values()
	else:
		values = data
	for i in range(len(values)):
		if values[i] is Array \
				or values[i] is Dictionary:
			values[i] = convert_vectors(values[i])
		elif values[i] is String:
			if values[i].length() > 0:
				if values[i][0] == "(" \
						and values[i][-1] == ")":
					var vector_type = 1
					for character in values[i]:
						vector_type += int(character == ",")
					values[i] = "Vector" + str(vector_type) + values[i]
					values[i] = str_to_var(values[i])
		if data is Dictionary:
			data[keys[i]] = values[i]
		else:
			data[i] = values[i]
	return data


func recursive_automatic_online_variable_getter(current_path: Object) -> Dictionary:
	var online_variables: Dictionary = {}
	for node in current_path.get_children():
		online_variables.merge(recursive_automatic_online_variable_getter(node))
	if "online" in current_path:
		var key: String = current_path.get_path()
		key = key.substr(len("/root/"))
		online_variables[key] = current_path.online
	return online_variables


func recursive_automatic_online_variable_setter(data: Dictionary, current_path = get_node("/root/")):
	var assign: bool
	for e_name in data.keys():
		assign = true
		if data[e_name] is Dictionary:
			var nv_nodes = current_path.get_children()
			for node in nv_nodes:
				if e_name == node.name:
					if e_name != Network.ID:
						recursive_automatic_online_variable_setter(data[e_name], node)
					assign = false
		if assign:
			if "online" in current_path:
				if e_name == "interpolated":
					for variable_name in current_path.online["interpolated"]:
						current_path.last_online_interpolated_variables[variable_name] = current_path.get(variable_name)
				current_path.online[e_name] = data[e_name]
			else:
				print("Variable online not found on: ", current_path.get_path(), " !")
				print("\tERROR: cannot assign ", e_name)
	return 0


# Select -> /part/ <- and press CTRL+D to jump on the next one !
# /request_functions/


func new_request(request_type: String, game: int = 0, request_content: Dictionary = {}, password: String = "0"):
	request_content["head"] = \
	{
		"request": request_type, 
		"game": str(game), 
		"password": password
	}
	var request_headers: PackedStringArray = \
	[
		"Content-Type: application/json", 
		"content-length: " + str(JSON.stringify(request_content).length())
	]
	request_time = Tools.time
	return request(Network.SERVER, request_headers, HTTPClient.METHOD_POST, JSON.stringify(request_content))


func _request_completed(result: int, _response: int, _headers: PackedStringArray, body):
	if !result:
		body = body.get_string_from_utf8()
		if body:
			if body[0] == "{":
				var json = JSON.new()
				json.parse(body)
				body = json.get_data()
				body = convert_vectors(body)
			if request_action != pass_request_action \
					and !request_action.is_null() \
					and request_action is Callable:
				request_action.call(body)
				request_action = pass_request_action
			request_delay += (Tools.time - request_time) * .1
			request_time = Tools.time
			request_delay /= 1.1
	else:
		print("The connection with the server has failed !")
		print("\tERROR: ", error_string(result), " (", result, ")")


# Select -> /part/ <- and press CTRL+D to jump on the next one !
# /automatic_request_calling/


func online_sync():
	new_request("get", 1)
	print("Set Delay: ", int(request_delay * 1000), "ms")
	request_action = \
	func f(data):
		var request_content = recursive_automatic_online_variable_getter(Tools.Game.get_node("Players/" +Network.ID))
		new_request("set", 1, request_content)
		print("Get Delay: ", int(request_delay * 1000), "ms")
		recursive_automatic_online_variable_setter(data)


func online_get():
	new_request("get", 1)
	request_action = \
	func f(data):
		if data is Dictionary:
			recursive_automatic_online_variable_setter(data)
		else:
			print("Cannot assign online variables !")
			print("\tERROR: !(data is Dictionary): data = ", data)


func online_set():
	var request_content = recursive_automatic_online_variable_getter(Tools.Game.get_node("Players/" + Network.ID))
	request_content["Game/Players/"+Network.ID]["delay"] = request_delay
	new_request("set", 1, request_content)
