extends Node3D
class_name ModelBase

var head_bone_index:int=-1
var model_skeleton:Skeleton3D

var model_keybinds:Dictionary={}:
	get=_get_model_keybinds


func _ready():
	var recursive_find_skeleton=func(node,recursive_func):
		if node is Skeleton3D:return node
		for child in node.get_children(true):
			var val=recursive_func.call(child,recursive_func)
			
			if val is Skeleton3D:return val
	
	model_skeleton=recursive_find_skeleton.call(self,recursive_find_skeleton) as Skeleton3D
	
	

func _get_model_keybinds()->Dictionary:
	return {}


func _model_update(model_data)->void:
	_head_rotation_update(model_data["Quaternion"].current_value)



func _eyes_update(data:Dictionary)->void:
	pass

func _eyebrows_update(data:Dictionary)->void:
	pass

func _head_update(data:Dictionary)->void:pass

func _head_rotation_update(quaternion_data:Quaternion)->void:
	if head_bone_index==-1||model_skeleton==null:return
	
	var head_rotation=(-quaternion_data).get_euler()
	head_rotation.z*=-1
	model_skeleton.set_bone_pose_rotation(head_bone_index,Quaternion.from_euler(head_rotation))

