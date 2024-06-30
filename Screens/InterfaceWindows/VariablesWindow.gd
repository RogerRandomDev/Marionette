extends Window


func load_changable_variables(changed_type:int=0)->void:
	for variable in $ScrollContainer/PanelContainer/VBoxContainer.get_children():
		variable.queue_free()
	
	var environment=get_tree().current_scene.world_scene.loaded_environment
	var variables={}
	if environment!=null:variables=environment.get('EnvironmentValues')
	if variables==null:variables={}
	var env_lbl=Label.new()
	env_lbl.text="ENVIRONMENT"
	env_lbl.horizontal_alignment=1
	$ScrollContainer/PanelContainer/VBoxContainer.add_child(env_lbl)
	
	for variable in variables:
		var variable_content=variables[variable]
		load_variable(variable_content,variable,changed_type==0)
			
	#now model variables
	var model=get_tree().current_scene.world_scene.loaded_model
	variables={}
	if model!=null:variables=model.get('ModelValues')
	if variables==null:variables={}
	var mdl_lbl:Label=Label.new()
	mdl_lbl.text="MODEL"
	mdl_lbl.horizontal_alignment=1
	$ScrollContainer/PanelContainer/VBoxContainer.add_child(mdl_lbl)
	
	for variable in variables:
		var variable_content=variables[variable]
		load_variable(variable_content,variable,changed_type==1)
	
	

func load_variable(variable_content,variable,update_value:bool=false)->void:
	match variable_content.type:
		"Range":
			var holder=HBoxContainer.new()
			var text=Label.new()
			var edit=SpinBox.new()
			holder.add_child(text)
			holder.add_child(edit)
			text.size_flags_horizontal=Control.SIZE_EXPAND_FILL
			text.text=variable
			if variable_content.has("range"):
				edit.min_value=variable_content.range.x
				edit.max_value=variable_content.range.y
				edit.step=variable_content.range.z
			if variable_content.has("func"):
				edit.value_changed.connect(variable_content["func"])
			
			if update_value:edit.value_changed.emit(variable_content.default)
			
			$ScrollContainer/PanelContainer/VBoxContainer.add_child(holder)
		"ColorPicker":
			var holder=HBoxContainer.new()
			var text=Label.new()
			var edit=ColorPickerButton.new()
			holder.add_child(text)
			holder.add_child(edit)
			text.size_flags_horizontal=Control.SIZE_EXPAND_FILL
			text.text=variable
			if variable_content.has("func"):
				edit.color_changed.connect(variable_content["func"])
			edit.text="Change"
			if variable_content.has("default"):
				edit.color=variable_content.default
			
			if update_value:edit.color_changed.emit(variable_content.default)
			
			$ScrollContainer/PanelContainer/VBoxContainer.add_child(holder)
		"ImagePicker":
			var holder=HBoxContainer.new()
			var text=Label.new()
			var edit=Button.new()
			var disable_button=Button.new()
			holder.add_child(text)
			holder.add_child(edit)
			holder.add_child(disable_button)
			text.size_flags_horizontal=Control.SIZE_EXPAND_FILL
			text.text=variable
			var dialog=FileDialog.new()
			dialog.access=FileDialog.ACCESS_FILESYSTEM
			dialog.filters=PackedStringArray(["*.png","*.webp","*.jpeg","*.jpg","*.svg"])
			dialog.initial_position=Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
			dialog.file_mode=FileDialog.FILE_MODE_OPEN_FILE
			dialog.size=Vector2(256,320)
			disable_button.text="X"
			disable_button.pressed.connect(variable_content["func"].bind("NOTHING_SELECTED"))
			dialog.close_requested.connect(dialog.hide)
			if variable_content.has("func"):
				dialog.file_selected.connect(variable_content["func"])
				
			edit.text="Change"
			edit.pressed.connect(dialog.show)
			
			if update_value and variable_content.has("default"):dialog.file_selected.emit(variable_content["default"])
			holder.add_child(dialog)
			$ScrollContainer/PanelContainer/VBoxContainer.add_child(holder)
