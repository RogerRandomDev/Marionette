extends Window


var model_controls:Array=[
	{
		"type":"Label",
		"text":"TRACKING TOGGLES"
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
	}
]


func _ready():
	connect_controls()

func connect_controls():
	for control in model_controls:
		match control.type:
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
				$PanelContainer/VBoxContainer.add_child(holder)
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
				
				var check_against=$PanelContainer/VBoxContainer.get_node_or_null(control["forceDefaultIfFalse"])
				if check_against:
					check_against.get_child(1).toggled.connect(func(v):edit.value_changed.emit(edit.value))
				edit.value_changed.connect(
					func(new_value):
						if check_against and not check_against.get_child(1).button_pressed:
							new_value=control["default"]
						print(new_value)
						var _data=OSF_LOAD.get_child(1)._dataInfo
						if _data==null:return
						if control.has("controlled_value"):
							var values_controled=control["controlled_value"].split(",")
							if control["controlled_value"].find(",")<0:
								values_controled=[control["controlled_value"]]
							print(values_controled)
							for controlled_value in values_controled:
								_data["features"][controlled_value]["interpolation"]=new_value
				)
				
				
				text.size_flags_horizontal=Control.SIZE_EXPAND_FILL
				$PanelContainer/VBoxContainer.add_child(holder)
	var change_model:Button = %ChangeModel
	change_model.pressed.connect(
		func():
			#should open UI to select file to load.
			pass
	)
