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
				var cam=Globals.world.get_node("SubViewport/Camera3D")
				cam.position=Vector3(0.0,0.5,cam.position.z)
)
	},
	{
		"type":"Function",
		"text":"Reset Camera Rotation",
		"func":(
			func():
				var model=Globals.world.get_node_or_null("SubViewport/MODEL")
				if model:model.rotation=Vector3.ZERO
)
	},
	{
		"type":"Function",
		"text":"Reset Camera Zoom",
		"func":(
			func():
				var cam=Globals.world.get_node("SubViewport/Camera3D")
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
		"meta_on_model":true,
		"default":true
	},
	{
		"type":"Interpolation",
		"Name":"GazeInterp",
		"controlled_value":"leftEyeGaze,rightEyeGaze,horizontalLooking,verticalLooking",
		"text":"Gaze Interpolation",
		"range":Vector2(0,1),
		"meta_on_model":true,
		"forceDefaultIfFalse":"GazeTracked",
		"default":0.0
	},
	{
		"type":"Toggle",
		"Name":"HeadTrackedRot",
		"text":"Track Head Rotation",
		"meta_on_model":true,
		"default":true
	},
	{
		"type":"Interpolation",
		"Name":"HeadRotInterp",
		"controlled_value":"Quaternion,Euler",
		"text":"Head Rotation Interpolation",
		"meta_on_model":true,
		"range":Vector2(0,1),
		"forceDefaultIfFalse":"HeadTrackedRot",
		"default":0.0
	},
	{
		"type":"Toggle",
		"Name":"HeadTrackedPos",
		"meta_on_model":true,
		"text":"Track Head Position",
		"default":false
	},
	{
		"type":"Interpolation",
		"Name":"HeadPosInterp",
		"controlled_value":"Translation",
		"meta_on_model":true,
		"text":"Head Position Interpolation",
		"range":Vector2(0,1),
		"forceDefaultIfFalse":"HeadTrackedPos",
		"default":0.0
	},
	{
		"type":"Function",
		"text":"Calibrate Gaze",
		"func":func():Globals.FaceHandler._dataInfo.calibrateFeatures(["leftEyeGaze","rightEyeGaze"]),
		"align":1
	},
	{
		"type":"Function",
		"text":"Calibrate Facing Direction",
		"func":func():Globals.FaceHandler._dataInfo.calibrateFeatures(["Quaternion","Euler"]),
		"align":1
	},
	{
		"type":"Function",
		"text":"Calibrate Head Position",
		"func":(func():
			Globals.FaceHandler._dataInfo.calibrateFeature("Translation")
			Globals.CalibratedPosition=Globals.FaceHandler._dataInfo.getHeadPosition())
			,
		"align":1
		
	}
]
var reference_inputs:Dictionary={}

func _ready():
	#gives time to load OSFData from the config
	connect_controls.call_deferred()

func connect_controls():
	var OSF_config=Globals.FaceHandler._dataInfo.features
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
							var on_node=Globals.world
							if control["toggle_on_node"]!="./":on_node=on_node.get_node(control["toggle_on_node"])
							on_node.set(control["toggle_property"],is_pressed)
							if control.get("meta_on_model",false):
								if Globals.world.loaded_model==null:return
								var model=Globals.world.loaded_model
								model.set_meta("meta_var_modelwindow_%s"%control['Name'],is_pressed)
					)
				
				reference_inputs[control["Name"]]=edit
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
				if control.has("func"):
					edit.value_changed.connect(control.get("func"))
				else:
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
							if control.get("meta_on_model",false):
								if Globals.world.loaded_model==null:return
								var model=Globals.world.loaded_model
								model.set_meta("meta_var_modelwindow_%s"%control['Name'],new_value)
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
				reference_inputs[control["Name"]]=edit
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

			var new_file_path=file_path+"/Model.tscn"
			var old_file_path=chosen_model
			chosen_model=file_path
			store_current_loaded_model(old_file_path)
			ShapeBinds.clear_binds()
			await Globals.world.load_model(load(new_file_path).instantiate(),old_file_path)
			
			load_model_config()
			
			
	)
	visibility_changed.connect(func():self.size=Vector2(320,360))
	
	
	#await get_tree().process_frame
	if chosen_model!="":%ChooseNewModel.file_selected.emit(chosen_model)


func load_model_config()->void:
	var config_path=chosen_model.replace("res://","user://")+".conf"
	var model=Globals.world.loaded_model
	
	if FileAccess.file_exists(config_path):
		var file=FileAccess.open(config_path,FileAccess.READ)
		var model_config=file.get_var(true)
		file.close()
		#re-add the binds on the model for shapekeys
		ShapeBinds.clear_binds()
		for shape_bind in model_config.ModelShapeKeyBinds:
			if len(shape_bind)<6 or String(shape_bind[5])=="":continue
			var mesh=model.get_node(String(shape_bind[5]))
			ShapeBinds.create_bind(
				mesh,
				shape_bind[0],
				shape_bind[1],
				shape_bind[2],
				shape_bind[3],
				shape_bind[4],
				Globals.FaceHandler._dataInfo.features[shape_bind[6]],
				shape_bind[6]
				)
		model.head_bone_index=model_config.ModelSkeletonBoneData.HeadBone
		model.eye_bone_indices=model_config.ModelSkeletonBoneData.EyeBones
		var stored_vars=model_config.get("ModelVariables",null)
		if stored_vars!=null:
			model.update_stored_variables(stored_vars)
			update_meta_vars(stored_vars)
		
	Globals.ShapeKeysInterfaceWindow.load_new_model_shapekeys.emit(model)


##stores config data for the current loaded model
func store_current_loaded_model(file_path:String="")->void:
	if Globals.world.loaded_model==null:return
	var model_config=get_store_data()
	var file=FileAccess.open(file_path.replace("res://","user://")+".conf",FileAccess.WRITE)
	file.store_var(model_config,true)
	file.close()


func get_store_data()->Dictionary:
	var model_config={
		"ModelShapeKeyBinds":ShapeBinds.get_config_format(Globals.world.loaded_model),
		"ModelSkeletonBoneData":{
			"HeadBone":Globals.world.loaded_model.head_bone_index,
			"EyeBones":Globals.world.loaded_model.eye_bone_indices
		},
		"ModelVariables":Globals.world.loaded_model.get_stored_variables()
	}
	return model_config

##values stored as meta in the model for updating here
func update_meta_vars(stored_vars)->void:
	for key in stored_vars:
		if key.begins_with("meta_var_modelwindow_"):
			var key_true=key.trim_prefix("meta_var_modelwindow_")
			var edit = reference_inputs[key_true]
			if edit is SpinBox:
				edit.value=stored_vars[key]
				edit.value_changed.emit(stored_vars[key])
				
			if edit is Button:
				edit.button_pressed=stored_vars[key]
				edit.toggled.emit(stored_vars[key])
		if key.begins_with("meta_var_global_"):
			var key_true=key.trim_prefix("meta_var_global_")
			Globals._set(key_true,stored_vars[key])
