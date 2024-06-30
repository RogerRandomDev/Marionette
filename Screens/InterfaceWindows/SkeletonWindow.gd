extends Window

signal new_model_loaded(model:Node3D)


func _ready():
	var tree:Tree=$ScrollContainer/PanelContainer/HBox/Tree
	var headbonecheckbox=$ScrollContainer/PanelContainer/HBox/VBoxContainer/HBoxContainer/HeadBoneCheckBox
	var resetskeletonbutton=$ScrollContainer/PanelContainer/HBox/VBoxContainer/ResetSkeletonPose
	
	
	#set the bone index to selected bone index
	#unless you are unchecking it and it matched, in which case, it sets no head bone
	headbonecheckbox.toggled.connect(func(pressed):
		var loaded_model=get_tree().current_scene.world_scene.loaded_model
		var selected=tree.get_selected()
		if selected == null:return
		if pressed:
			loaded_model.head_bone_index=selected.get_meta("bone_index",-1)
		else:
			if loaded_model.head_bone_index==selected.get_meta("bone_index",-1):
				loaded_model.head_bone_index=-1
		)
	
	#handles loading in the new model's skeleton
	new_model_loaded.connect(func(model:Node3D):
		tree.clear()
		var skeleton_node:Skeleton3D=null
		var skeleton_finder=func(from_node:Node3D,recursive_func):
			if from_node is Skeleton3D:return from_node
			for child in from_node.get_children(true):
				if child is Node3D:
					var val=recursive_func.call(child,recursive_func)
					if val is Skeleton3D:return val
				
		
		skeleton_node=skeleton_finder.call(model,skeleton_finder) as Skeleton3D
		#this is in case you done messed up
		#why did you forget to bone them
		#thats cruel, give structural rigidity to that fleshy goo
		if skeleton_node==null:return
		var bone_builder=func(bone_ind,recursive_func,attached_tree_item:TreeItem):
			var bone_name=skeleton_node.get_bone_name(bone_ind)
			var bone_tree_item=attached_tree_item.create_child()
			bone_tree_item.set_meta("bone_index",bone_ind)
			bone_tree_item.set_text(0,bone_name)
			for bone_child in skeleton_node.get_bone_children(bone_ind):
				recursive_func.call(bone_child,recursive_func,bone_tree_item)
		
		var root_item=(tree as Tree).create_item()
		
		bone_builder.call(0,bone_builder,root_item)
		)
	
	resetskeletonbutton.pressed.connect(func():
		var skeleton_node:Skeleton3D=get_tree().current_scene.world_scene.loaded_model.model_skeleton
		if skeleton_node==null:return
		skeleton_node.reset_bone_poses()
		
		)
	tree.item_selected.connect(func():
		var selected=tree.get_selected()
		if selected.get_meta("bone_index",-1)<0:headbonecheckbox.button_pressed=false
		else:headbonecheckbox.button_pressed=get_tree().current_scene.world_scene.loaded_model.head_bone_index==selected.get_meta("bone_index",-1)
		)



