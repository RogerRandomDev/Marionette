extends Control

var world_scene=preload("res://Screens/UserWorld.tscn").instantiate()
var world_control_interface=preload("res://Screens/UserControlInterface.tscn").instantiate()


func _ready():
	add_child(world_control_interface)
	add_child(world_scene)

