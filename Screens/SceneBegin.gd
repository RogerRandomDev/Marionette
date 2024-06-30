extends Control

var world_scene=preload("res://Screens/UserWorld.tscn").instantiate()
var world_control_interface=preload("res://Screens/UserControlInterface.tscn").instantiate()
#var world_scene_2d=preload("res://Screens/2DUserWorld.tscn").instantiate()

func _ready():
	add_child(world_control_interface)
	var world_holder_3d=CanvasLayer.new()
	world_holder_3d.add_child(world_scene)
	#add_child(world_scene)
	add_child(world_holder_3d)
	world_holder_3d.layer=-1
	
	load_available_models_and_environments()


func load_available_models_and_environments()->void:
	if !DirAccess.dir_exists_absolute("user://Models"):
		DirAccess.make_dir_recursive_absolute("user://Models")
	if !DirAccess.dir_exists_absolute("user://Environments"):
		DirAccess.make_dir_recursive_absolute("user://Environments")
	
	var models=DirAccess.open("user://Models")
	var environments=DirAccess.open("user://Environments")
	
	for model in models.get_files():
		if model.ends_with(".pck") or model.ends_with(".zip"):
			ProjectSettings.load_resource_pack("%s/%s"%[models.get_current_dir(),model],false)
	world_control_interface.model_window.get_node("ChooseNewModel").load_model_list(models.get_files())
	
	for environment in environments.get_files():
		if environment.ends_with(".pck") or environment.ends_with(".zip"):
			ProjectSettings.load_resource_pack("%s/%s"%[environments.get_current_dir(),environment],false)
	world_control_interface.environment_window.get_node("ChooseNewEnvironment").load_environment_list(environments.get_files())


##save current layout as a config to use when loading next time
func _exit_tree():
	var model=world_scene.get_node_or_null("SubViewport/MODEL")
	var model_basis=Basis()
	if model:model_basis=model.transform.basis
	
	
	var config_data={
		"Camera":Transform3D(model_basis,world_scene.get_node("SubViewport/Camera3D").transform.origin),
		"ModelPath":world_control_interface.model_window.chosen_model,
		"EnvironmentPath":world_control_interface.environment_window.chosen_environment,
		"OSFData":OSF_LOAD.get_node("OpenSeeFaceHandler")._dataInfo.get_storage_dictionary()
	}
	
	var file=FileAccess.open("user://World0.conf",FileAccess.WRITE)
	file.store_var(config_data,true)
	file.close()
##load current layout from config if it finds one
func _enter_tree():
	if !FileAccess.file_exists("user://World0.conf"):return
	var file=FileAccess.open("user://World0.conf",FileAccess.READ)
	var config_data=file.get_var(true)
	
	world_scene.get_node("SubViewport/Camera3D").transform.origin=config_data["Camera"].origin
	world_control_interface.model_window.chosen_model=config_data["ModelPath"]
	world_control_interface.environment_window.chosen_environment=config_data["EnvironmentPath"]
	await get_tree().process_frame
	OSF_LOAD.get_node("OpenSeeFaceHandler")._dataInfo.load_storage_dictionary(config_data["OSFData"])
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	var model=world_scene.get_node_or_null("SubViewport/MODEL")
	if model:
		model.transform.basis=config_data["Camera"].basis
