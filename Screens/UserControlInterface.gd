extends Control

var model_window=preload("res://Screens/InterfaceWindows/ModelWindow.tscn").instantiate()
var environment_window=preload("res://Screens/InterfaceWindows/EnvironmentWindow.tscn").instantiate()
var keybinds_window=preload("res://Screens/InterfaceWindows/KeyBindsWindow.tscn").instantiate()
var variables_window=preload("res://Screens/InterfaceWindows/VariablesWindow.tscn").instantiate()

func _ready():
	OSF_LOAD.close_requested.connect(_on_tracking_toggled.bind(false))
	model_window.close_requested.connect(_on_model_toggled.bind(false))
	environment_window.close_requested.connect(_on_environment_toggled.bind(false))
	keybinds_window.close_requested.connect(_on_key_binds_toggled.bind(false))
	variables_window.close_requested.connect(_on_variables_toggled.bind(false))
	add_child(model_window)
	add_child(environment_window)
	add_child(keybinds_window)
	add_child(variables_window)
	
	resized.connect(
		func():
			get_tree().root.get_viewport()
	)
	
	

func _input(event):
	if event is InputEventKey and event.echo==false and event.pressed and event.as_text()=="Escape":
		visible=!visible
		for button in %Basic.get_children():
			if not button is Button:continue
			button.button_pressed=false
			button.toggled.emit(false)

func _on_tracking_toggled(toggled_on):
	%Basic/Tracking.button_pressed=toggled_on
	OSF_LOAD.show()
	if !toggled_on:
		OSF_LOAD.hide()


#func _OSF_event(event):
	#print(event)
	#Input.parse_input_event(event)


func _on_model_toggled(toggled_on):
	if toggled_on:
		model_window.show()
	else:
		model_window.hide()


func _on_environment_toggled(toggled_on):
	if toggled_on:
		environment_window.show()
	else:
		environment_window.hide()


func _on_key_binds_toggled(toggled_on):
	if toggled_on:
		keybinds_window.show()
	else:
		keybinds_window.hide()


func _on_variables_toggled(toggled_on):
	if toggled_on:
		variables_window.show()
	else:
		variables_window.hide()

