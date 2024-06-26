extends Node3D
var last_ref

# Called when the node enters the scene tree for the first time.
func _ready():
	load_OSF()
func load_OSF()->void:
	var face_handler=OSF_LOAD.get_node("OpenSeeFaceHandler")
	var data_ref=face_handler._dataInfo
	if data_ref==last_ref:
		return
	last_ref=data_ref
	if data_ref!=null:data_ref.info_updated.connect(get_child(1)._model_update)
