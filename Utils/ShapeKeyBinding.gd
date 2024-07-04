extends Node
class_name ShapeKeyBinding

var shapekeyBinds:Array=[]



func create_bind(mesh,key,scale,offset,min,max,feature,feature_name)->bindRes:
	var newBind = bindRes.new(mesh,key,scale,offset,min,max,feature,feature_name)
	shapekeyBinds.push_back(newBind)
	return newBind


func removeBind(bind)->void:
	shapekeyBinds.erase(bind)

func clear_binds()->void:
	for bind in range(len(shapekeyBinds),0,-1):shapekeyBinds.remove_at(bind-1)



func _process(delta):
	update_binds()

func update_binds()->void:
	for bind in shapekeyBinds:bind.update()


func get_config_format(loaded_model)->Array:
	var output=[]
	shapekeyBinds.map(func(v):output.push_back(v.get_config_format(loaded_model)))
	return output

func get_bind_id(bind_link)->int:
	return Globals.FaceHandler._dataInfo.features.values().find(bind_link)+1



class bindRes extends Resource:
	var key_id:int=-1
	var on_mesh:MeshInstance3D
	var scale_feature:float=1.0
	var offset_feature:float=0.0
	var feature_min:float=-1.0
	var feature_max:float=1.0
	
	var feature_linked:Dictionary={}
	var feature_name:String=""
	
	func _init(mesh:MeshInstance3D,key:int,scale:float,offset:float,min:float,max:float,feature:Dictionary,feature_n:String)->void:
		on_mesh=mesh;key_id=key;scale_feature=scale;offset_feature=offset;feature_linked=feature;feature_min=min;feature_max=max;feature_name=feature_n;
	
	func update()->void:
		if not feature_linked["current_value"] is float or on_mesh==null:return
		var value=clamp(feature_linked["current_value"]*scale_feature+offset_feature,feature_min,feature_max)
		on_mesh.set_blend_shape_value(key_id,value)
	func get_config_format(loaded_model)->Array:
		return [key_id,
		scale_feature,
		offset_feature,
		feature_min,
		feature_max,
		loaded_model.get_path_to(on_mesh),
		feature_name
		]
		
