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
	

func _input(event):
	if event is InputEventKey and event.as_text()=="K":
		if $PouchParticles/PotatoPouchBurst.emitting:return
		$PouchParticles/PotatoPouchBurst.emitting=true
		$PouchParticles/PotatoPouchBurstStart.emitting=true


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
	var floop_angle=(floopy_amount)*PI*0.375
	#left_ear
	$TheGoober/Armature/Skeleton3D.set_bone_pose_rotation(8,Quaternion.from_euler(Vector3(-PI*0.5+floop_angle,-PI*0.5,0)))
	#right_ear
	$TheGoober/Armature/Skeleton3D.set_bone_pose_rotation(9,Quaternion.from_euler(Vector3(-PI*0.5+floop_angle,PI*0.5,0)))
	
	
	var right_eye_up_down:Vector3=Vector3.FORWARD*model_data.rightEyeGaze.current_value
	right_eye_up_down=Vector3(-0.5*right_eye_up_down.x,0.0,-0.5*right_eye_up_down.y).clamp(Vector3(-0.5,-0.1,-0.01),Vector3(0.5,0.5,0.5))
	
	var ave_updown=right_eye_up_down+Vector3(0.5,0.0,0.5)
	($TheGoober/Armature/Skeleton3D/EyeWhite/EyeWhite as MeshInstance3D).mesh.surface_get_material(0).set_shader_parameter("eye_pos",Vector2(1.0-ave_updown.x,1.0-ave_updown.z))
	
