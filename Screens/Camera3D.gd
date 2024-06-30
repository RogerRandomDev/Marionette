extends Camera3D


var move_sensitivity:float=0.00625
var rotation_sensitivity:float=0.00625
var zoom_rate:float=0.00625

func _input(event):
	###
	### CAMERA ZOOM
	###
	if event is InputEventMouseButton and event.button_index in [4,5] and get_parent().get_parent().zoomCamera:
		position.z+=((event.button_index-4.5)*2)*zoom_rate
	###
	### CAMERA POSITION
	###
	if event is InputEventMouseMotion and get_parent().get_parent().moveCamera and event.button_mask%2==1:
		var old_position=project_position(event.position+event.relative,position.z)
		var new_position=project_position(get_viewport().get_mouse_position(),position.z)
		position+=Vector3(
			new_position.x-old_position.x,
			new_position.y-old_position.y,
			0
		)
	if event is InputEventMouseMotion and get_parent().get_parent().rotateCamera and event.button_mask-event.button_mask%2==2:
		var old_position=project_position(event.position+event.relative,position.z)
		var new_position=project_position(get_viewport().get_mouse_position(),position.z)
		var motion=new_position-old_position
		var cam_rot=event.relative
		var model=get_parent().get_node("MODEL")
		if model:
			model.rotation+=Vector3(cam_rot.y,cam_rot.x,0.0)*rotation_sensitivity
		
