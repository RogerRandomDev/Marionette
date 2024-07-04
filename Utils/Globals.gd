extends Node



var current_globals:Dictionary={}

func remove_global(global_name:String)->void:current_globals.erase(global_name)

func _get(property):
	if property=="current_globals":return current_globals
	if current_globals.has(property):return current_globals[property]
func _set(property, value):
	if property=="current_globals":return false
	current_globals[property]=value
	return true
