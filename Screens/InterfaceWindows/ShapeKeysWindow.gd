extends Window


signal load_new_model_shapekeys(model:Node3D)


func _ready()->void:
	#needs implemented to bind shapekeys with features still
	var feature_name_option=$ScrollContainer/PanelContainer/HBox/VBoxContainer/ShapeBindFeatureOption
	var feature_offset=$ScrollContainer/PanelContainer/HBox/VBoxContainer/ShapeBindFeatureOffsetValue
	var feature_scale=$ScrollContainer/PanelContainer/HBox/VBoxContainer/ShapeBindFeatureScaleValue
	var feature_min=$ScrollContainer/PanelContainer/HBox/VBoxContainer/ShapeBindFeatureClampMinValue
	var feature_max=$ScrollContainer/PanelContainer/HBox/VBoxContainer/ShapeBindFeatureClampMaxValue
	#is used to check what a shapekey is doing
	var feature_current=$ScrollContainer/PanelContainer/HBox/VBoxContainer/ShapeBindFeatureCurrentValue
	
	var shapekey_tree:Tree=$ScrollContainer/PanelContainer/HBox/Tree
	#recursively constructs the list of model data and the structure for the scene
	load_new_model_shapekeys.connect((func(model:Node3D):
		(shapekey_tree as Tree).clear()
		var tree_root=(shapekey_tree as Tree).create_item()
		tree_root.set_meta("is_shapekey",false)
		
		var recursive_func=(func(node,recursive_func):
			for child in node.get_children():
				if child is MeshInstance3D:
					var child_item=tree_root.create_child()
					child_item.set_text(0,child.name)
					var list=child.get_property_list().filter(func(v):
						return v.name.contains("blend_shapes/")
						)
					
					child_item.set_meta("is_shapekey",false)
					
					list=list.map(func(v):return v.name)
					
					for blend_shape in list:
						var shape_name=blend_shape.trim_prefix("blend_shapes/")
						var key_item=child_item.create_child()
						var index=child.find_blend_shape_by_name(shape_name)
						key_item.set_text(0,shape_name)
						key_item.set_meta("is_shapekey",true)
						key_item.set_meta("on_instance",child)
						key_item.set_meta("selected_feature_index",0)
						var possible_binds=ShapeBinds.shapekeyBinds.filter(func(v):return v.on_mesh==child and v.key_id==index)
						if len(possible_binds):
							key_item.set_meta("bind",possible_binds[0])
							key_item.set_meta("selected_feature_index",Globals.FaceHandler._dataInfo.features.keys().find(possible_binds[0].feature_name)+1)
						key_item.set_meta("index",index)
				#loop time
				recursive_func.call(child,recursive_func)
			)
		#initiate the recursive loops
		recursive_func.call(model,recursive_func)
		)
	)
	
	
	(shapekey_tree as Tree).nothing_selected.connect(func():
		for child in $ScrollContainer/PanelContainer/HBox/VBoxContainer.get_children():
			child.hide()
		)
	
	
	(shapekey_tree as Tree).item_selected.connect(func():
		feature_max.apply()
		feature_min.apply()
		feature_offset.apply()
		feature_scale.apply()
		
		#behold once more, my absolutely horendous technique
		#if it takes a frame or two to do something
		#wait a frame or two to continue
		await get_tree().process_frame
		#await get_tree().process_frame
		
		var selected=shapekey_tree.get_selected()
		
		if not selected.get_meta("is_shapekey",false):
			shapekey_tree.nothing_selected.emit()
			return
		var selected_name=selected.get_text(0)
		for child in $ScrollContainer/PanelContainer/HBox/VBoxContainer.get_children():
			child.show()
		feature_current.value=selected.get_meta("on_instance",null).get_blend_shape_value(selected.get_meta("index",0))
		var old_bind=null if not selected.has_meta("bind") else selected.get_meta("bind",null)
		if old_bind:
			feature_max.value=old_bind.feature_max
			feature_min.value=old_bind.feature_min
			feature_offset.value=old_bind.offset_feature
			feature_scale.value=old_bind.scale_feature
			feature_current.hide()
		else:
			feature_max.value=0
			feature_min.value=0
			feature_offset.value=0
			feature_scale.value=1
			feature_current.show()
			
		feature_name_option.select(selected.get_meta("selected_feature_index",0))
		)
	
	
	feature_current.value_changed.connect(func(new_value):
		var selected=shapekey_tree.get_selected()
		var instance=selected.get_meta("on_instance",null)
		if instance==null or not selected.get_meta("is_shapekey"):return
		(instance as MeshInstance3D).set_blend_shape_value(selected.get_meta("index",0),new_value)
	)
	
	
	feature_name_option.item_selected.connect(func(index):
		var selected=shapekey_tree.get_selected()
		var instance=selected.get_meta("on_instance",null)
		if instance==null or not selected.get_meta("is_shapekey"):return
		
		var item_name=(feature_name_option as OptionButton).get_item_text(index)
		if item_name=="None":
			ShapeBinds.removeBind(selected.get_meta("bind",null))
			selected.remove_meta("bind");selected.set_meta("selected_feature_index",0)
			feature_current.show()
		else:
			var old_bind=null if not selected.has_meta("bind") else selected.get_meta("bind",null)
			if old_bind==null:
				selected.set_meta("bind",ShapeBinds.create_bind(
					instance,
					selected.get_meta("index",0),
					feature_scale.value,
					feature_offset.value,
					feature_min.value,
					feature_max.value,
					Globals.FaceHandler._dataInfo.features[item_name],
					item_name
				))
			else:
				old_bind.feature_name=item_name
				old_bind.feature_linked=Globals.FaceHandler._dataInfo.features.values()[index-1]
			feature_current.hide()
			selected.set_meta("selected_feature_index",index)
	)
	
	feature_offset.value_changed.connect(func(new_value):
		var selected=shapekey_tree.get_selected()
		var instance=selected.get_meta("on_instance",null)
		if instance==null or not selected.get_meta("is_shapekey"):return
		var old_bind=null if not selected.has_meta("bind") else selected.get_meta("bind",null)
		if old_bind==null:return
		old_bind.offset_feature=new_value
		)
	feature_scale.value_changed.connect(func(new_value):
		var selected=shapekey_tree.get_selected()
		var instance=selected.get_meta("on_instance",null)
		if instance==null or not selected.get_meta("is_shapekey"):return
		var old_bind=null if not selected.has_meta("bind") else selected.get_meta("bind",null)
		if old_bind==null:return
		old_bind.scale_feature=new_value
		)
	feature_min.value_changed.connect(func(new_value):
		var selected=shapekey_tree.get_selected()
		var instance=selected.get_meta("on_instance",null)
		if instance==null or not selected.get_meta("is_shapekey"):return
		var old_bind=null if not selected.has_meta("bind") else selected.get_meta("bind",null)
		if old_bind==null:return
		old_bind.feature_min=new_value
		)
	
	feature_max.value_changed.connect(func(new_value):
		var selected=shapekey_tree.get_selected()
		var instance=selected.get_meta("on_instance",null)
		if instance==null or not selected.get_meta("is_shapekey"):return
		var old_bind=null if not selected.has_meta("bind") else selected.get_meta("bind",null)
		if old_bind==null:return
		old_bind.feature_max=new_value
		)
	load_feature_names(Globals.FaceHandler._dataInfo.features.keys())
	




func load_feature_names(feature_names)->void:
	$ScrollContainer/PanelContainer/HBox/VBoxContainer/ShapeBindFeatureOption.clear()
	$ScrollContainer/PanelContainer/HBox/VBoxContainer/ShapeBindFeatureOption.add_item("None")
	for feature in feature_names:
		$ScrollContainer/PanelContainer/HBox/VBoxContainer/ShapeBindFeatureOption.add_item(feature)

