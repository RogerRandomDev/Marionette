extends Node
class_name KeyBinds


var current_binds:Dictionary={
	
}

func load_binds(bind_data)->void:
	for bind in bind_data:add_bind(bind,bind_data[bind].keys,[bind_data[bind].func])


func add_bind(bind_name:String,bind_event:String,bind_actions:Array[Callable],overwrite_bind:bool=true)->void:
	if overwrite_bind or not current_binds.has(bind_name):
		current_binds[bind_name]={
			"on_keys":bind_event,
			"actions_bound":bind_actions
		}
	else:if current_binds.has(bind_name):
		current_binds[bind_name]={
			"on_keys":current_binds[bind_name],
			"actions_bound":bind_actions
		}




func update_bind_keys(bind_name:String,new_keys:String)->void:
	if not current_binds.has(bind_name):return
	current_binds[bind_name]["on_keys"]=new_keys

func update_bind_actions(bind_name:String,new_actions:Array[Callable],replace:bool=true)->void:
	if not current_binds.has(bind_name):return
	if replace:current_binds[bind_name]["actions_bound"]=new_actions
	else:current_binds[bind_name]["actions_bound"].append_array(new_actions)

func clear_binds()->void:
	for bind in current_binds:remove_bind(bind)


func remove_bind(bind_name:String)->void:current_binds.erase(bind_name)


func save_binds()->Dictionary:
	var binds_saved=current_binds.duplicate(true)
	for bind in binds_saved:binds_saved[bind]=binds_saved[bind]["on_keys"]
	return binds_saved


func _input(event):
	if not event is InputEventKey or not event.is_pressed() or event.is_echo():return
	var event_txt=event.as_text()
	for bind_name in current_binds:
		var bind=current_binds[bind_name]
		if bind.on_keys==event_txt:
			for method in bind.actions_bound:method.call()

