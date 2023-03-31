extends Node

# Parts:
# Select -> /part/ <- and press CTRL+D to jump on the next one !
# /process/
# /tools/
# /network_setup/

@onready var _NetworkInterface = preload("res://Network/Network Interface.tscn")

var Getter: HTTPRequest
var Setter: HTTPRequest

const TYPE_MANUAL:      int = 0 # Default network interface status
const TYPE_SYNCHONIZER: int = 1
const TYPE_GETTER:      int = 2
const TYPE_SETTER:      int = 3

var   ID:            String = OS.get_unique_id()
var   SERVER:        String = "http://tremisabdoul.go.yj.fr/game/main.php"

var is_processing: bool = false

# Select -> /part/ <- and press CTRL+D to jump on the next one !
# /process/


func _physics_process(_delta):
	if int(Tools.time / 5) != Tools.ticks[5] \
			and (Getter.request_delay + Setter.request_delay) > .0001:
		print("Get Delay: ", int(Getter.request_delay * 1000), "ms")
		print("Set Delay: ", int(Setter.request_delay * 1000), "ms")
		for Player in get_node("../Game/Players").get_children():
			if Player.name != ID:
				print(Player.name + "'s Set Delay: ", int(Player.online["delay"] * 1000), "ms")


# Select -> /part/ <- and press CTRL+D to jump on the next one !
# /tools/


func is_master(node):
	return node.name == ID


# Select -> /part/ <- and press CTRL+D to jump on the next one !
# /network_setup/


func initialize_network():
	for type in [TYPE_GETTER, TYPE_SETTER]:
		var NetworkSyncronizer = _NetworkInterface.instantiate()
		NetworkSyncronizer.type = type
		NetworkSyncronizer.name = "Network Syncronizer " + str(type)
		Tools.Game.add_child(NetworkSyncronizer)
	Getter = Tools.Game.get_node("Network Syncronizer " + str(TYPE_GETTER))
	Setter = Tools.Game.get_node("Network Syncronizer " + str(TYPE_SETTER))
