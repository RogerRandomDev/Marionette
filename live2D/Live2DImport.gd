extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	import_live2d("res://live2D/kei_basic_free/kei_basic_free.moc3")
	#import_live2d("res://live2D/test_files/test.cmo3")

#god this makes me suffer
#i really hate proprietary formats
#especially when it's binary data, thats just hell to pull from.

#i know that face binds for it are each name-separated by 58 bytes of 0
#just the names of each of them though.



func import_live2d(file_path)->void:
	var file_bytes=FileAccess.get_file_as_bytes(file_path)
	
	print(file_bytes)
	
	

