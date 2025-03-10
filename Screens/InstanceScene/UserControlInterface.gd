extends Control

var model_window=preload("res://Screens/InterfaceWindows/ModelWindow.tscn").instantiate()
var environment_window=preload("res://Screens/InterfaceWindows/EnvironmentWindow.tscn").instantiate()
var keybinds_window=preload("res://Screens/InterfaceWindows/KeyBindsWindow.tscn").instantiate()
var variables_window=preload("res://Screens/InterfaceWindows/VariablesWindow.tscn").instantiate()
var shapekeys_window=preload("res://Screens/InterfaceWindows/ShapeKeysWindow.tscn").instantiate()
var skeleton_window=preload("res://Screens/InterfaceWindows/SkeletonWindow.tscn").instantiate()
var instance_window=preload("res://Screens/InterfaceWindows/InstancedResourcesWindow.tscn").instantiate()


var window_buttons={
	"Tracking":OSF_LOAD,
	"Model":model_window,
	"Environment":environment_window,
	"Variables":variables_window,
	"KeyBinds":keybinds_window,
	"ShapeKeys":shapekeys_window,
	"Skeleton":skeleton_window,
	"Instances":instance_window
}



func _ready():
	for button in window_buttons:
		#load the global acccess to the value
		Globals._set(button+"InterfaceWindow",window_buttons[button])
		
		var btn=Button.new()
		btn.text=button
		%Basic.add_child(btn)
		btn.name=button
		var pressed_func=(func(toggled):
			btn.button_pressed=toggled
			if toggled:
				window_buttons[button].show()
			else:
				window_buttons[button].hide()
			)
		btn.toggle_mode=true
		btn.toggled.connect(pressed_func)
		window_buttons[button].close_requested.connect(pressed_func.bind(false))
		if window_buttons[button].get_parent()==null:add_child(window_buttons[button])
	
	

func _input(event):
	if event is InputEventKey and event.echo==false and event.pressed and event.as_text()=="Escape":
		visible=!visible
		for button in %Basic.get_children():
			if not button is Button:continue
			button.button_pressed=false
			button.toggled.emit(false)
