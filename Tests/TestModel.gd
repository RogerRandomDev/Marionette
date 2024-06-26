extends Node3D



var big_eyes:bool=false
var big_eye_timer:Timer=Timer.new()

var eye_positions:Array=[
	
]
func _ready():
	big_eye_timer.wait_time=0.25
	big_eye_timer.one_shot=true
	big_eye_timer.timeout.connect(func():
		big_eyes=false
		)
	add_child(big_eye_timer)
	
	eye_positions.push_back(
		($TheGoober/Armature/Skeleton3D as Skeleton3D).get_bone_pose_position(7)
	)
	eye_positions.push_back(
		($TheGoober/Armature/Skeleton3D as Skeleton3D).get_bone_pose_position(9)
	)
	


func _model_update(model_data)->void:
	#need to move this into a different function later
	
	
	
	###
	### rotate goober's head to match my own
	###
	var head_rotation=(-model_data.Quaternion.current_value).get_euler()
	head_rotation.z*=-1
	$TheGoober/Armature/Skeleton3D.set_bone_pose_rotation(5,Quaternion.from_euler(head_rotation))
	
	###
	### flop the ears when i open my mouth/widen my mouth
	###
	var floopy_amount=(model_data.EyeBrowUpDownLeft.current_value+model_data.EyeBrowUpDownRight.current_value)*0.5
	
	var floop_angle=(floopy_amount)*PI*0.25
	#left_ear
	$TheGoober/Armature/Skeleton3D.set_bone_pose_rotation(10,Quaternion.from_euler(Vector3(-PI*0.5+floop_angle,-PI*0.5,0)))
	#right_ear
	$TheGoober/Armature/Skeleton3D.set_bone_pose_rotation(11,Quaternion.from_euler(Vector3(-PI*0.5+floop_angle,PI*0.5,0)))
	###
	### pupils get bigger if i move my eyebrows up really high
	###
	var eye_expand_cutoff:float=0.30625
	var eye_expand_multiplier:float=0.5
	var eyeSize=Vector3.ONE
	var eyeScale=(model_data.EyeBrowUpDownLeft.current_value+model_data.EyeBrowUpDownRight.current_value)*0.5
	if eyeScale>eye_expand_cutoff:
		big_eyes=true
		big_eye_timer.stop()
	else:
		if big_eyes and big_eye_timer.is_stopped():
			big_eye_timer.start()
	eyeSize+=Vector3.ONE*eye_expand_cutoff*float(big_eyes)
	$TheGoober/Armature/Skeleton3D.set_bone_pose_scale(7,eyeSize)
	$TheGoober/Armature/Skeleton3D.set_bone_pose_scale(9,eyeSize)
	
	#$TheGoober/Armature/Skeleton3D.set_bone_pose_position(7,eye_positions[0]+(gaze_offset*model_data.leftEyeGaze.current_value)*Vector3(1,0,1))
	#print(model_data.leftEyeGaze.current_value)
	var left_eye_up_down:Vector3=Vector3.FORWARD*model_data.leftEyeGaze.current_value
	left_eye_up_down=Vector3(-0.03*left_eye_up_down.x,0.0,-0.03*left_eye_up_down.y).clamp(Vector3(-0.01,0.0,-0.01),Vector3(0.01,0.0,0.01))
	
	var right_eye_up_down:Vector3=Vector3.FORWARD*model_data.rightEyeGaze.current_value
	right_eye_up_down=Vector3(-0.03*right_eye_up_down.x,0.0,-0.03*right_eye_up_down.y).clamp(Vector3(-0.01,0.0,-0.01),Vector3(0.01,0.0,0.01))
	
	$TheGoober/Armature/Skeleton3D.set_bone_pose_position(7,
	left_eye_up_down+eye_positions[0]
	)
	
	$TheGoober/Armature/Skeleton3D.set_bone_pose_position(9,
	right_eye_up_down+eye_positions[1]
	)
