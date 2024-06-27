extends Node3D
var last_ref

var loaded_model:Node=null

func _ready():
	var scene=load("res://Tests/TestModel.tscn").instantiate()
	load_model(scene)

func load_OSF()->void:
	var face_handler=OSF_LOAD.get_node("OpenSeeFaceHandler")
	var data_ref=face_handler._dataInfo
	if data_ref==last_ref:
		return
	last_ref=data_ref
	if data_ref!=null:data_ref.info_updated.connect(get_child(1)._model_update)


func load_model(model:Node)->void:
	if loaded_model:loaded_model.queue_free()
	
	loaded_model=model
	add_child(model)
	load_OSF.call_deferred()
