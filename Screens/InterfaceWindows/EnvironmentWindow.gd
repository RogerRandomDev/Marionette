extends Window


var chosen_environment:String=""



# Called when the node enters the scene tree for the first time.
func _ready():
	var change_environment:Button = %ChangeEnvironment
	change_environment.pressed.connect(
		func():
			%ChooseNewEnvironment.show()
	)
	%ChooseNewEnvironment.focus_exited.connect(func():%ChooseNewEnvironment.hide())
	%ChooseNewEnvironment.close_requested.connect(func():%ChooseNewEnvironment.hide())
	%ChooseNewEnvironment.file_selected.connect(
		func(file_path):
			var world=get_tree().current_scene.world_scene
			chosen_environment=file_path
			file_path=file_path+"/Environment.tscn"
			world.load_environment(load(file_path).instantiate())
			
	)
	visibility_changed.connect(func():self.size=Vector2(340,360))
	await get_tree().process_frame
	if chosen_environment!="":%ChooseNewEnvironment.file_selected.emit(chosen_environment)









