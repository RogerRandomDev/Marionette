extends TextureRect
class_name InteractiveSprite


func _init(tex:ImageTexture=null)->void:
	if tex==null:return
	texture=tex
	expand_mode=TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	custom_minimum_size=tex.get_image().get_size()
	set_meta("ImageSize",tex.get_image().get_size())
	mouse_filter=Control.MOUSE_FILTER_STOP

var image_scaling:Vector2=Vector2.ONE

var selected:bool=false
func _input(event):
	if event is InputEventMouseButton and event.button_index==1:
		selected=event.pressed and get_global_rect().has_point(event.position)
		if selected and event.double_click:
			open_doubleclick_menu()
		
		
	if event is InputEventMouseMotion and selected:
		#only if moving and holding it down
		if event.button_mask!=1:return
		position+=event.relative
	if event is InputEventMouseButton and (event.button_index==5||event.button_index==4) and selected:
		var img_size=Vector2(get_meta("ImageSize",Vector2.ONE))
		image_scaling-=Vector2(2,2)*(event.button_index-4.5)/((img_size.x+img_size.y)*0.5)*(image_scaling*4)
		#so we can keep it relatively centered for the scaling
		var old_size=custom_minimum_size
		custom_minimum_size=image_scaling*img_size
		var change=old_size-custom_minimum_size
		position+=change*0.5
		
		
		size=Vector2.ZERO

##not yet set up or integrated but should have it later for more useful tools
func open_doubleclick_menu()->void:
	pass

