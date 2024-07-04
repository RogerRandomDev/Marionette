extends PanelContainer

var root_instance_item:TreeItem

var preview_images:Array=[]


# Called when the node enters the scene tree for the first time.
func _ready():
	root_instance_item=(%InstanceList as Tree).create_item()
	
	%InstanceList.item_selected.connect(func():
		for child in root_instance_item.get_children():child.set_editable(0,false)
		var selected=%InstanceList.get_selected()
		selected.set_editable.call_deferred(0,true)
		%InstancePreviewTex.texture=selected.get_icon(0)
		)
	
	%InstanceList.item_edited.connect(func():
		var selected=%InstanceList.get_selected()
		var new_instance_name=selected.get_text(0)
		for item in root_instance_item.get_children():
			if item==selected:continue
			#cant name 2 things the same
			if item.get_text(0)==new_instance_name:
				#i love meta so damn much for things like this
				new_instance_name=selected.get_meta("NAME")
				break
		#if it did change
		if new_instance_name!=selected.get_meta("NAME"):
			#rename the instance file instead of making a new one
			DirAccess.rename_absolute(
				"user://Instances/%s.conf"%selected.get_meta("NAME"),
				"user://Instances/%s.conf"%new_instance_name
			)
		selected.set_text(0,new_instance_name)
		selected.set_meta("NAME",new_instance_name)
		
		
		)
	%CreateInstance.pressed.connect(func():
		var new_item=root_instance_item.create_child()
		var name_inst=root_instance_item.get_child_count()
		while true:
			var loop=false
			for child in root_instance_item.get_children():
				if child.get_text(0)=="Instance #%s"%name_inst:
					name_inst+=1
					loop=true
			if not loop:break
		new_item.set_text(0,"Instance #%s"%str(name_inst))
		new_item.set_meta("NAME",new_item.get_text(0))
		new_item.set_editable(0,false)
		var file=FileAccess.open("user://Instances/%s.conf"%new_item.get_text(0),FileAccess.WRITE)
		file.store_var({"EMPTY":true},true)
		file.close()
		
		)
	
	%DeleteInstance.pressed.connect(func():
		if not %InstanceList.get_selected():return
		%ConfirmDeleteInstance.show()
		)
	%ConfirmDeleteInstance.confirmed.connect(func():
		var selected=%InstanceList.get_selected()
		
		var instance_name=selected.get_text(0)
		DirAccess.remove_absolute("user://Instances/%s.conf"%instance_name)
		root_instance_item.remove_child(selected)
		selected.free()
		)
	
	%LaunchInstance.pressed.connect(func():
		var selected=%InstanceList.get_selected()
		if selected==null:return
		var instance_name=selected.get_text(0)
		Globals.current_instance=instance_name
		get_tree().change_scene_to_file("res://Screens/InstanceScene/SceneBegin.tscn")
		)
	
	
	Globals.current_instance="SELECTSCREEN"
	load_instance_list()




func load_instance_list()->void:
	if !DirAccess.dir_exists_absolute("user://Instances"):
		DirAccess.make_dir_absolute("user://Instances")
	var dir=DirAccess.open("user://Instances")
	for instance_name in dir.get_files():
		var new_item=root_instance_item.create_child()
		new_item.set_text(0,instance_name.trim_suffix(".conf"))
		new_item.set_meta("NAME",new_item.get_text(0))
		var file=FileAccess.open(dir.get_current_dir()+"/"+instance_name,FileAccess.READ)
		var conf_data=file.get_var(true)
		if not conf_data.has("PreviewScreenshot"):continue
		var screenshot_data=conf_data.PreviewScreenshot
		var decompressed_screenshot=screenshot_data.data.decompress(screenshot_data.size.x*screenshot_data.size.y*3,3)
		var img=Image.create_from_data(screenshot_data.size.x,screenshot_data.size.y,false,4,decompressed_screenshot)
		var tex=ImageTexture.create_from_image(img)
		preview_images.push_back(tex)
		new_item.set_icon(0,tex)
		new_item.set_icon_max_width(0,128)
		%InstanceList.resized.connect(func():
			new_item.set_icon_max_width(0,min(%InstanceList.size.x*0.5,256))
			)
		
		
