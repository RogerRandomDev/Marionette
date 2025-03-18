extends ModelBase



var big_eyes:bool=false
var big_eye_timer:Timer=Timer.new()
var blink_time_left:float=0.0

var eye_positions:Array=[
	
]
func _ready():
	super._ready()
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
	$TheGoober/AnimationPlayer.play("StandHandsAtSide")
	
func _process(delta):
	blink_time_left=max(blink_time_left-delta,0.0)

func _input(event):
	if event.as_text().to_lower()=="q" and not event.is_echo() and event.is_pressed():
		$GPUParticles3D.emitting=true


func _model_update(model_data)->void:
	super._model_update(model_data)
	
	###
	### flop the ears when i open my mouth/widen my mouth
	###
	var floopy_amount=(model_data.EyeBrowUpDownLeft.current_value+model_data.EyeBrowUpDownRight.current_value)*0.5
	var floop_angle=(floopy_amount)*PI*0.375
	#left_ear
	$TheGoober/Armature/Skeleton3D.set_bone_pose_rotation(8,Quaternion.from_euler(Vector3(-PI*0.5+floop_angle,-PI*0.5,0)))
	#right_ear
	$TheGoober/Armature/Skeleton3D.set_bone_pose_rotation(9,Quaternion.from_euler(Vector3(-PI*0.5+floop_angle,PI*0.5,0)))
	
	var left_eye_up_down:Vector3=Vector3.FORWARD*model_data.leftEyeGaze.current_value
	var right_eye_up_down:Vector3=Vector3.FORWARD*model_data.rightEyeGaze.current_value
	right_eye_up_down=Vector3(-0.5*right_eye_up_down.x,0.0,-0.5*right_eye_up_down.y).clamp(Vector3(-0.5,-0.1,-0.5),Vector3(0.5,0.5,0.5))
	left_eye_up_down=Vector3(-0.5*left_eye_up_down.x,0.0,-0.5*left_eye_up_down.y).clamp(Vector3(-0.5,-0.1,-0.5),Vector3(0.5,0.5,0.5))
	
	var ave_updown=0.5*(right_eye_up_down+left_eye_up_down)+Vector3(0.5,0.0,0.5)
	($TheGoober/Armature/Skeleton3D/EyeWhite/EyeWhite as MeshInstance3D).mesh.surface_get_material(0).set_shader_parameter("eye_pos",Vector2(1.0-ave_updown.x,1.0-ave_updown.z))
	
	###
	### BLINK CONTROL
	###
	var blink_tolerance:float=-0.8
	var is_blink=(
		(model_data.EyeLeft.current_value+model_data.EyeRight.current_value)*0.5-min(ave_updown.z,0)<blink_tolerance
	)
	if is_blink:blink_time_left=0.125
	is_blink = is_blink or blink_time_left!=0.0
	
	
	$TheGoober/Armature/Skeleton3D/EyeWhite/EyeWhite.scale=Vector3(1,float(!is_blink)*0.9+0.1,1)

func _points2d_update(points)->void:
	points = points.target_value
	if len(points)==0:return
	var custom_offset=(((points[0]+points[16])*0.5)-Globals.CalibratedPosition )/Globals.CameraResolution
	$TheGoober.position=Vector3(custom_offset.x,-custom_offset.y,0)*body_motion_scale



func _get_model_keybinds()->Dictionary:
	return {
		"ShowHammer":{
			"keys":"Ctrl+Q",
			"func":func():$FryHammer.visible=!$FryHammer.visible
			
		}
	}





