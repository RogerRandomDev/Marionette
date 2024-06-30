extends Node
class_name ShapeKeyBinding

var shapekeyBinds:Array=[]



func create_bind(mesh,key,scale,offset,min,max,feature)->bindRes:
	var newBind = bindRes.new(mesh,key,scale,offset,min,max,feature)
	shapekeyBinds.push_back(newBind)
	return newBind


func removeBind(bind)->void:
	shapekeyBinds.erase(bind)


func _process(delta):
	for bind in shapekeyBinds:bind.update()




class bindRes extends Resource:
	var key_id:int=-1
	var on_mesh:MeshInstance3D
	var scale_feature:float=1.0
	var offset_feature:float=0.0
	var feature_min:float=-1.0
	var feature_max:float=1.0
	
	var feature_linked:Dictionary={}
	
	
	func _init(mesh:MeshInstance3D,key:int,scale:float,offset:float,min:float,max:float,feature:Dictionary)->void:
		on_mesh=mesh;key_id=key;scale_feature=scale;offset_feature=offset;feature_linked=feature;feature_min=min;feature_max=max
	
	func update()->void:
		var value=clamp(feature_linked["current_value"]*scale_feature+offset_feature,feature_min,feature_max)
		on_mesh.set_blend_shape_value(key_id,value)
		
	
	
