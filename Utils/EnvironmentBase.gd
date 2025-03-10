extends Node3D
class_name EnvironmentBase



var EnvironmentValues:Dictionary={}:
	get=get_environment_values


signal testing(val)

var test_val:float=0.0

func _ready():
	#test code. it works as intended
	#_bind_to_property(testing,self,"test_val")
	#
	#testing.emit(420.69)
	#
	#print(test_val)
	
	
	pass


func attach_to_camera(node:Node,offset:Vector3=Vector3.ZERO)->void:
	if node.get_parent()!=null:
		node.reparent(get_viewport().get_camera_3d(),false)
	get_viewport().get_camera_3d().add_child(node)
	node.position=offset
	self.tree_exiting.connect(
		func():
			if node!=null:node.queue_free()
	)

func _bind_to_property(signal_ref:Signal,object_linked,obj_parameter_name:String)->void:
	var method:Callable=bound_property_update.bind(obj_parameter_name,object_linked)
	#for when the object stops existing
	object_linked.tree_exited.connect((func():signal_ref.disconnect(method)),4)
	print(object_linked.name)
	signal_ref.connect(method)

func bound_property_update(value,parameter,object)->void:
	object.set(parameter,value)

func get_environment_values()->Dictionary:return {}
