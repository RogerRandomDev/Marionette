extends Sprite3D
class_name InteractiveSprite3D


func _init(tex:ImageTexture=null)->void:
	if tex==null:return
	texture=tex
