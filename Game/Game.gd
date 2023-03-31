extends Node

# Parts:
# Select -> /part/ <- and press CTRL+D to jump on the next one !
# /process/
# /initialisation_functions/

@onready var _Player = preload("res://Game/Player.tscn")

# Select -> /part/ <- and press CTRL+D to jump on the next one !
# /process/


func _ready():
	Tools.Game = self
	Network.initialize_network()
	initialize_players()

 
# Select -> /part/ <- and press CTRL+D to jump on the next one !
# /initialisation_functions/


func initialize_players():
	
	#var Player
	#Player = _Player.instantiate()
	#Player.name = Network.ID
	#get_node("Players").add_child(Player)
	
	Network.Getter.new_request("get", 1)
	Network.Getter.request_action = \
	func f(data):
		if !(data is Dictionary):
			print("Cannot resolve online players initianisation !")
			print("\tERROR: !(data is Dictionary): data = ", data)
			call_deferred("initialize_players")
			return
		if !("Game" in data.keys()):
			return
		if !("Players" in data["Game"].keys()):
			return
		var Player
		for player_name in data["Game"]["Players"].keys():
			if player_name != Network.ID:
				Player = _Player.instantiate()
				Player.name = player_name
				get_node("Players").add_child(Player)
		Player = _Player.instantiate()
		Player.name = Network.ID
		get_node("Players").add_child(Player)
		Network.is_processing = true
