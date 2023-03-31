extends Node

var Game: Node

var time: float = 0
var ticks: Dictionary = \
{
	5: 0
}


func _process(delta):
	for key in ticks.keys():
		ticks[key] = int(time / key)
	time += delta
