extends Window
var chosen_model:String=""

var camera_controls:Array=[
	{
		"type":"Label",
		"text":"CAMERA CONTROLS",
		"align":1
	},
	{
		"type":"Toggle",
		"Name":"CameraPosition",
		"text":"Camera Position",
		"default":false,
		"toggle_on_node":"./",
		"toggle_property":"moveCamera"
	},
	{
		"type":"Toggle",
		"Name":"CameraRotation",
		"text":"Camera Rotation",
		"default":false,
		"toggle_on_node":"./",
		"toggle_property":"rotateCamera"
	},
	{
		"type":"Toggle",
		"Name":"CameraZoom",
		"text":"Camera Zoom",
		"default":false,
		"toggle_on_node":"./",
		"toggle_property":"zoomCamera"
	},
	{
		"type":"Function",
		"text":"Reset Camera Position",
		"func":(
			func():
				var world=get_tree().current_scene.world_scene
				var cam=world.get_node("SubViewport/Camera3D")
				cam.position=Vector3(0.0,0.5,cam.position.z)
)
	},
	{
		"type":"Function",
		"text":"Reset Camera Rotation",
		"func":(
			func():
				var world=get_tree().current_scene.world_scene
				var model=world.get_node_or_null("SubViewport/MODEL")
				if model:model.rotation=Vector3.ZERO
)
	},
	{
		"type":"Function",
		"text":"Reset Camera Zoom",
		"func":(
			func():
				var world=get_tree().current_scene.world_scene
				var cam=world.get_node("SubViewport/Camera3D")
				cam.position.z=1.0
)
	}
]


var model_controls:Array=[
	{
		"type":"Label",
		"text":"TRACKING TOGGLES",
		"align":1
	},
	{
		"type":"Toggle",
		"Name":"GazeTracked",
		"text":"Track Gaze",
		"default":true
	},
	{
		"type":"Interpolation",
		"Name":"GazeInterp",
		"controlled_value":"leftEyeGaze,rightEyeGaze",
		"text":"Gaze Interpolation",
		"range":Vector2(0,1),
		"forceDefaultIfFalse":"GazeTracked",
		"default":0.0
	},
	{
		"type":"Toggle",
		"Name":"HeadTrackedRot",
		"text":"Track Head Rotation",
		"default":true
	},
	{
		"type":"Interpolation",
		"Name":"HeadRotInterp",
		"controlled_value":"Quaternion,Euler",
		"text":"Head Rotation Interpolation",
		"range":Vector2(0,1),
		"forceDefaultIfFalse":"HeadTrackedRot",
		"default":0.0
	},
	{
		"type":"Toggle",
		"Name":"HeadTrackedPos",
		"text":"Track Head Position",
		"default":false
	},
	{
		"type":"Interpolation",
		"Name":"HeadPosInterp",
		"controlled_value":"Translation",
		"text":"Head Position Interpolation",
		"range":Vector2(0,1),
		"forceDefaultIfFalse":"HeadTrackedPos",
		"default":0.0
	},
	{
		"type":"Function",
		"text":"Calibrate Gaze",
		"func":func():OSF_LOAD.get_node("OpenSeeFaceHandler")._dataInfo.calibrateFeatures(["leftEyeGaze","rightEyeGaze"]),
		"align":1
	},
	{
		"type":"Function",
		"text":"Calibrate Facing Direction",
		"func":func():OSF_LOAD.get_node("OpenSeeFaceHandler")._dataInfo.calibrateFeatures(["Quaternion","Euler"]),
		"align":1
	},
	{
		"type":"Function",
		"text":"Calibrate Head Position",
		"func":func():OSF_LOAD.get_node("OpenSeeFaceHandler")._dataInfo.calibrateFeature("Translation"),
		"align":1
		
	}
]


func _ready():
	#gives time to load OSFData from the config
	await get_tree().process_frame
	connect_controls()

func connect_controls():
	var OSF_config=OSF_LOAD.get_node("OpenSeeFaceHandler")._dataInfo.features
	var all_controls=camera_controls.duplicate()
	all_controls.append_array(model_controls)
	for control in all_controls:
		match control.type:
			"Label":
				var text=Label.new()
				text.horizontal_alignment=control["align"]
				text.text=control.text
				text.size_flags_horizontal=Control.SIZE_EXPAND_FILL
				$ScrollContainer/PanelContainer/VBoxContainer.add_child(text)
			"Toggle":
				var holder=HBoxContainer.new()
				var text=Label.new()
				var edit=CheckButton.new()
				if control.has("Name"):holder.name=control["Name"]
				
				holder.add_child(text)
				holder.add_child(edit)
				text.text=control.text
				edit.button_pressed=control.default
				text.size_flags_horizontal=Control.SIZE_EXPAND_FILL
				$ScrollContainer/PanelContainer/VBoxContainer.add_child(holder)
				
				if control.has("toggle_on_node"):
					edit.toggled.connect(
						func(is_pressed):
							var on_node=get_tree().current_scene.world_scene
							if control["toggle_on_node"]!="./":on_node=on_node.get_node(control["toggle_on_node"])
							on_node.set(control["toggle_property"],is_pressed)
					)
				
				
			"Interpolation":
				var holder=HBoxContainer.new()
				var text=Label.new()
				var edit=SpinBox.new()
				holder.add_child(text)
				holder.add_child(edit)
				if control.has("Name"):holder.name=control["Name"]
				edit.step=0.01
				if control.has("range"):
					edit.min_value=control.range.x
					edit.max_value=control.range.y
				text.text=control.text
				edit.value=control.default
				
				var check_against=$ScrollContainer/PanelContainer/VBoxContainer.get_node_or_null(control["forceDefaultIfFalse"])
				if check_against:
					check_against.get_child(1).toggled.connect(func(v):edit.value_changed.emit(edit.value))
				edit.value_changed.connect(
					func(new_value):
						if check_against and not check_against.get_child(1).button_pressed:
							new_value=control["default"]
						var _data=OSF_LOAD.get_child(1)._dataInfo
						if _data==null:return
						if control.has("controlled_value"):
							var values_controled=control["controlled_value"].split(",")
							if control["controlled_value"].find(",")<0:
								values_controled=[control["controlled_value"]]
							for controlled_value in values_controled:
								_data["features"][controlled_value]["interpolation"]=new_value
				)
				if(control.has("controlled_value")):
					var values_controled=control["controlled_value"].split(",")
					if control["controlled_value"].find(",")<0:
						values_controled=[control["controlled_value"]]
					var value_used=values_controled[0]
					edit.value=OSF_config[value_used]["interpolation"]
					edit.value_changed.emit(edit.value)
				
				
				text.size_flags_horizontal=Control.SIZE_EXPAND_FILL
				$ScrollContainer/PanelContainer/VBoxContainer.add_child(holder)
			"Function":
				var edit=Button.new()
				edit.text=control.text
				edit.pressed.connect(control.func)
				
				edit.size_flags_horizontal=Control.SIZE_SHRINK_CENTER
				if control.has("align"):
					edit.size_flags_horizontal=control["align"]
				
				
				$ScrollContainer/PanelContainer/VBoxContainer.add_child(edit)
				
	var change_model:Button = %ChangeModel
	change_model.pressed.connect(
		func():
			%ChooseNewModel.show()
	)
	%ChooseNewModel.focus_exited.connect(func():%ChooseNewModel.hide())
	%ChooseNewModel.close_requested.connect(func():%ChooseNewModel.hide())
	%ChooseNewModel.file_selected.connect(
		func(file_path):
			var world=get_tree().current_scene.world_scene
			chosen_model=file_path
			file_path=file_path+"/Model.tscn"
			
			world.load_model(load(file_path).instantiate())
	)
	visibility_changed.connect(func():self.size=Vector2(320,360))
	
	
	await get_tree().process_frame
	if chosen_model!="":%ChooseNewModel.file_selected.emit(chosen_model)
	
