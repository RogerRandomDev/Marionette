extends Node3D
class_name ModelBase

var head_bone_index:int=-1
var eye_bone_indices:Array=[]
var eye_movement_range:float=0.75

var body_motion_scale:float=1.0


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
	


#not finished yet
#we need this implemented to list under variables still
func _get_model_variables()->Dictionary:
	var values={
		"MotionScale":{
			"type":"Range",
			"func":(func(new_value):self.body_motion_scale=new_value),
			"range":Vector3(0,1,0.01),
			"default":1
		}
		
	}
	
	
	return values
	

func _get_model_keybinds()->Dictionary:
	return {}


func _model_update(model_data)->void:
	if len(model_data["2DPoints"].current_value)>0:
		var offset_quat=((model_data["2DPoints"].current_value[0]+model_data["2DPoints"].current_value[16])*0.5)/Globals.CameraResolution
		#var quat_f=Quaternion.from_euler(model_data["Quaternion"].current_value.get_euler()-Vector3(offset_quat.y*PI-PI*0.4,offset_quat.x*PI-PI*0.4,0.0))
		_head_rotation_update(model_data["Quaternion"].current_value)
	_eyes_update({
		"leftEyeGaze":model_data["leftEyeGaze"],
		"rightEyeGaze":model_data["rightEyeGaze"]
	})
	_position_update(model_data["Translation"])
	_points2d_update(model_data["2DPoints"])
	_points3d_update(model_data["3DPoints"])



func _eyes_update(data:Dictionary)->void:
	if len(eye_bone_indices)==0 or model_skeleton==null:return
	var ave_gaze=Quaternion.from_euler(-(data.leftEyeGaze.current_value.get_euler()+data.rightEyeGaze.current_value.get_euler())*0.5*Vector3(1,-1,1))
	for bone in eye_bone_indices:
		var combined_gaze=Quaternion.from_euler(ave_gaze.get_euler()*eye_movement_range+model_skeleton.get_bone_rest(bone).basis.get_euler())
		model_skeleton.set_bone_pose_rotation(bone,combined_gaze)
	

func _eyebrows_update(_data:Dictionary)->void:
	pass

func _head_update(_data:Dictionary)->void:pass

func _head_rotation_update(quaternion_data:Quaternion)->void:
	
	if head_bone_index==-1||model_skeleton==null:return
	
	var head_rotation=(-quaternion_data).get_euler()
	head_rotation.z*=-1
	model_skeleton.set_bone_pose_rotation(head_bone_index,Quaternion.from_euler(head_rotation))

func _position_update(_data:Dictionary)->void:pass
func _points2d_update(_points)->void:pass
func _points3d_update(_points)->void:pass




func get_stored_variables()->Dictionary:
	var stored_values:Dictionary={}
	
	#store any meta with the prefix
	for meta in get_meta_list():
		if meta.begins_with("meta_var_"):
			stored_values[meta]=get_meta(meta)
	
	
	
	stored_values["MotionScale"]=body_motion_scale
	stored_values["meta_var_global_CalibratedPosition"]=Globals.CalibratedPosition
	
	
	
	return stored_values


func update_stored_variables(stored_values:Dictionary={})->void:
	if stored_values == null or stored_values.keys().size()==0:return
	var s=stored_values.get("MotionScale",1.0)
	if not s is float:
		if s is Vector2: s=s.x
	body_motion_scale = s as float;
	#any meta stored variable
	for key in stored_values.keys():
		if not key.begins_with("meta_var_"):continue
		set_meta(key,stored_values[key])




