extends Window
signal file_selected(file_path)


var tree_item:TreeItem=null

func _ready():
	$Tree.set_column_expand(0,true)
	$Tree.set_column_expand(1,false)
	tree_item=$Tree.create_item()
	
	$Tree.item_activated.connect(
		func():
			var selected=($Tree as Tree).get_selected()
			var path="res://Models/%s"%selected.get_text(0)
			file_selected.emit(path)
			hide()
	)


func load_model_list(list:PackedStringArray)->void:
	for child in tree_item.get_children():tree_item.remove_child(child)
	for item in list:
		var new_item=tree_item.create_child()
		new_item.set_text(0,item.split(".")[0])
		




