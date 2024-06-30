extends Window


@onready var KeyBindList:Tree=$ScrollContainer/PanelContainer/Tree





func load_keybinds()->void:
	KeyBindList.clear()
	var root_item=KeyBindList.create_item()
	KeyBindList.set_column_expand_ratio(0,3.0)
	KeyBindList.set_column_expand_ratio(1,1.0)
	
	for bind in ModelBinds.current_binds:
		var bind_data=ModelBinds.current_binds[bind]
		var bind_item=root_item.create_child()
		bind_item.set_text(0,bind)
		bind_item.set_text(1,bind_data.on_keys)
		bind_item.set_text_alignment(1,HORIZONTAL_ALIGNMENT_RIGHT)
		
	pass
