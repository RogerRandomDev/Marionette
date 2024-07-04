extends Window


var chosen_environment:String=""



# Called when the node enters the scene tree for the first time.
func _ready():
	connect_controls.call_deferred()
func connect_controls():
	var change_environment:Button = %ChangeEnvironment
	change_environment.pressed.connect(
		func():
			%ChooseNewEnvironment.show()
	)
	%ChooseNewEnvironment.focus_exited.connect(func():%ChooseNewEnvironment.hide())
	%ChooseNewEnvironment.close_requested.connect(func():%ChooseNewEnvironment.hide())
	%ChooseNewEnvironment.file_selected.connect(
		func(file_path):
			chosen_environment=file_path
			file_path=file_path+"/Environment.tscn"
			await Globals.world.load_environment(load(file_path).instantiate())
			Globals.VariablesInterfaceWindow.load_changable_variables.call_deferred(1)
	)
	visibility_changed.connect(func():self.size=Vector2(340,360))
	if chosen_environment!="":%ChooseNewEnvironment.file_selected.emit(chosen_environment)









