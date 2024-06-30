extends SubViewportContainer
var last_ref

var loaded_model:Node=null
var loaded_environment:Node=null

var moveCamera:bool=false
var rotateCamera:bool=false
var zoomCamera:bool=false

func _ready():
	get_tree().root.size
	get_tree().root.get_viewport().size_changed.connect(
		func():
			$SubViewport.size=Vector2.ZERO
			await get_tree().process_frame
			$SubViewport.size=size
	)
	get_tree().root.get_viewport().size_changed.emit()


func load_OSF()->void:
	var face_handler=OSF_LOAD.get_node("OpenSeeFaceHandler")
	var data_ref=face_handler._dataInfo
	last_ref=data_ref
	if data_ref!=null:data_ref.info_updated.connect(get_node("SubViewport/MODEL")._model_update)


func load_model(model:Node)->void:
	if loaded_model:loaded_model.queue_free()
	await get_tree().process_frame
	loaded_model=model
	$SubViewport.add_child(model)
	model.name="MODEL"
	load_OSF.call_deferred()
	get_tree().current_scene.world_control_interface.variables_window.load_changable_variables.call_deferred(0)
func load_environment(model:Node)->void:
	if loaded_environment:loaded_environment.queue_free()
	await get_tree().process_frame
	loaded_environment=model
	model.name="ENVIRONMENT"
	add_child(model)
	get_tree().current_scene.world_control_interface.variables_window.load_changable_variables.call_deferred(1)
	


