extends SubViewportContainer
var last_ref

var loaded_model:Node=null
var loaded_environment:Node=null

var moveCamera:bool=false
var rotateCamera:bool=false
var zoomCamera:bool=false

func _ready():
	pass


func load_OSF()->void:
	var data_ref=Globals.FaceHandler._dataInfo
	last_ref=data_ref
	if data_ref!=null:data_ref.bindEvent(get_node("SubViewport/MODEL")._model_update)
	#if data_ref!=null:data_ref.info_updated.connect(get_node("SubViewport/MODEL")._model_update)


func load_model(model:Node,old_path:String="")->void:
	if loaded_model:
		loaded_model.name="OLD_MODEL"
		loaded_model.queue_free()
	loaded_model=model
	$SubViewport.add_child(model)
	model.name="MODEL"
	load_OSF.call_deferred()
	Globals.VariablesInterfaceWindow.load_changable_variables(0)
	
	#load model keybinds
	ModelBinds.clear_binds()
	ModelBinds.load_binds(model.model_keybinds)
	ShapeBinds.clear_binds()
	Globals.KeyBindsInterfaceWindow.load_keybinds()
	Globals.ShapeKeysInterfaceWindow.load_new_model_shapekeys.emit(model)
	Globals.SkeletonInterfaceWindow.new_model_loaded.emit(model)
	


func load_environment(model:Node)->void:
	if loaded_environment:loaded_environment.free()
	loaded_environment=model
	model.name="ENVIRONMENT"
	add_child(model)
	
	Globals.VariablesInterfaceWindow.load_changable_variables.call_deferred(1)


func _input(event):
	$SubViewport/Camera3D._input(event)

