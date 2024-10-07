extends Control

var world_scene=preload("res://Screens/InstanceScene/UserWorld.tscn").instantiate()
var world_control_interface=preload("res://Screens/InstanceScene/UserControlInterface.tscn").instantiate()
#var world_scene_2d=preload("res://Screens/2DUserWorld.tscn").instantiate()

func _ready():
	#load global accessible link to it
	Globals.control_interface=world_control_interface;
	Globals.world=world_scene
	
	
	add_child(world_control_interface)
	var world_holder_3d=CanvasLayer.new()
	world_holder_3d.add_child(world_scene)
	#add_child(world_scene)
	add_child(world_holder_3d)
	world_holder_3d.layer=-1
	load_available_models_and_environments()
	_load_initial_config()


func load_available_models_and_environments()->void:
	if !DirAccess.dir_exists_absolute("user://Models"):
		DirAccess.make_dir_recursive_absolute("user://Models")
	if !DirAccess.dir_exists_absolute("user://Environments"):
		DirAccess.make_dir_recursive_absolute("user://Environments")
	
	var models=DirAccess.open("user://Models")
	var environments=DirAccess.open("user://Environments")
	var model_list=[]
	for model in models.get_files():
		if model.ends_with(".pck") or model.ends_with(".zip"):
			model_list.push_back(model)
			ProjectSettings.load_resource_pack("%s/%s"%[models.get_current_dir(),model],true)
			
	world_control_interface.model_window.get_node("ChooseNewModel").load_model_list(model_list)
	
	for environment in environments.get_files():
		if environment.ends_with(".pck") or environment.ends_with(".zip"):
			ProjectSettings.load_resource_pack("%s/%s"%[environments.get_current_dir(),environment],false)
	world_control_interface.environment_window.get_node("ChooseNewEnvironment").load_environment_list(environments.get_files())
	

##save current layout as a config to use when loading next time
func _notification(what):
	if what != NOTIFICATION_WM_CLOSE_REQUEST:return
	var model=world_scene.get_node_or_null("SubViewport/MODEL")
	var model_basis=Basis()
	if model:model_basis=model.transform.basis
	world_control_interface.visible=false
	
	
	var screen_data=get_viewport().get_texture().get_image()
	var screen_size=get_viewport().size
	var screen_ratio=1024.0/max(screen_size.x,screen_size.y)
	screen_ratio=min(1,screen_ratio)
	screen_size=Vector2i(screen_size*screen_ratio)
	
	screen_data.resize(screen_size.x,screen_size.y,Image.INTERPOLATE_LANCZOS)
	
	var config_data={
		"Camera":Transform3D(model_basis,world_scene.get_node("SubViewport/Camera3D").transform.origin),
		"ModelPath":world_control_interface.model_window.chosen_model,
		"EnvironmentPath":world_control_interface.environment_window.chosen_environment,
		"OSFData":OSF_LOAD.get_node("OpenSeeFaceHandler")._dataInfo.get_storage_dictionary(),
		"PreviewScreenshot":{
			"size":screen_size,
			"data":screen_data.get_data().compress(3)
		}
	}
	world_control_interface.model_window.store_current_loaded_model(world_control_interface.model_window.chosen_model)
	
	var file=FileAccess.open("user://Instances/%s.conf"%Globals.current_instance,FileAccess.WRITE)
	file.store_var(config_data,true)
	file.close()
	
	get_tree().quit()


##load current layout from config if it finds one
func _load_initial_config():
	if !FileAccess.file_exists("user://Instances/%s.conf"%Globals.current_instance):return
	var file=FileAccess.open("user://Instances/%s.conf"%Globals.current_instance,FileAccess.READ)
	var config_data=file.get_var(true)
	#if the config_data is just the default empty placeholder
	if config_data.has("EMPTY") and config_data["EMPTY"]:return
	
	world_scene.get_node("SubViewport/Camera3D").transform.origin=config_data["Camera"].origin
	world_control_interface.model_window.chosen_model=config_data["ModelPath"]
	world_control_interface.environment_window.chosen_environment=config_data["EnvironmentPath"]
	await get_tree().process_frame
	Globals.FaceHandler._dataInfo.load_storage_dictionary(config_data["OSFData"])
	#await get_tree().process_frame
	#await get_tree().process_frame
	#await get_tree().process_frame
	var model=world_scene.loaded_model
	if model:
		model.transform.basis=config_data["Camera"].basis
