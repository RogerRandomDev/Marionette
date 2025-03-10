extends EnvironmentBase


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
func get_environment_values()->Dictionary:
	return {
	"BackgroundColor":{
		"type":"ColorPicker",
		"func":(func(new_color):get_node("ColorRect").color=new_color),
		"default":Color(0,0,1.0)
	},
	"BackgroundImage":{
		"type":"ImagePicker",
		"func":(func(new_image_path):
			var t=ImageTexture.new()
			if new_image_path!="NOTHING_SELECTED":
				var img=Image.new()
				img.load(new_image_path)
				t=ImageTexture.create_from_image(img)
			self.get_node("TextureRect").texture=t
			
			)
		},
	"ColorDepth":{
		"type":"Range",
		"func":(func(new_value):get_node("ScreenShader").material_override.set_shader_parameter("color_depth",new_value)),
		"range":Vector3(0,8,1),
		"default":5
	},
	"ResolutionScale":{
		"type":"Range",
		"func":(func(new_value):get_node("ScreenShader").material_override.set_shader_parameter("resolution_scale",new_value)),
		"range":Vector3(0,8,1),
		"default":2
	}
	}
