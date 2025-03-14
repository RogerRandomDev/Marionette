extends SubViewportContainer
var last_ref

var loaded_model:Node=null
var loaded_environment:Node=null

var moveCamera:bool=false
var rotateCamera:bool=false
var zoomCamera:bool=false

func _ready():
	bindFileDrops()


func load_OSF()->void:
	var data_ref=Globals.FaceHandler._dataInfo
	last_ref=data_ref
	var model_node=get_node_or_null("SubViewport/MODEL")
	for child in get_node_or_null("SubViewport").get_children():
		print(child.name)
	if model_node!=null and data_ref!=null:
		data_ref.bindEvent(model_node._model_update)
		#model_node.tree_exiting.connect(func():data_ref.unbindEvent())
	#if data_ref!=null:data_ref.info_updated.connect(get_node("SubViewport/MODEL")._model_update)


func load_model(model:Node,old_path:String="")->void:
	if loaded_model:
		loaded_model.name="OLD_MODEL"
		loaded_model.queue_free()
	loaded_model=model
	$SubViewport.add_child(model)
	model.name="MODEL"
	Globals.world.load_OSF()
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


##allows you to drag-and-drop a file and for it to attempt to be loaded/handled
func bindFileDrops()->void:
	get_tree().root.files_dropped.connect(
		func(files:PackedStringArray):
			for file in files:
				#if the file was a png
				if file.ends_with(".png"):
					var default=InteractiveSprite.new(ImageTexture.create_from_image(Image.load_from_file(file)))
					add_child(default)
					default.global_position=get_global_mouse_position()-default.size*0.5
					
	)
