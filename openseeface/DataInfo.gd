extends RefCounted
class_name OSFDataInfo


@export var features:Dictionary={
	"EyeLeft": {
		"interpolation":0.0,
		"target_value":-1.0,
		"current_value":-1.0
	},
	"EyeRight": {
		"interpolation":0.0,
		"target_value":-1.0,
		"current_value":-1.0
	},
	"Blink":{
		"interpolation":0.5,
		"target_value":-1.0,
		"current_value":-1.0
	},
	"EyeBrowSteepnessLeft": {
		"interpolation":0.0,
		"target_value":-1.0,
		"current_value":-1.0
	},
	"EyeBrowUpDownLeft": {
		"interpolation":0.75,
		"target_value":-1.0,
		"current_value":-1.0
	},
	"EyeBrowQuirkLeft": {
		"interpolation":0.0,
		"target_value":-1.0,
		"current_value":-1.0
	},
	"EyeBrowSteepnessRight": {
		"interpolation":0.0,
		"target_value":-1.0,
		"current_value":-1.0
	},
	"EyeBrowUpDownRight": {
		"interpolation":0.75,
		"target_value":-1.0,
		"current_value":-1.0
	},
	"EyeBrowQuirkRight": {
		"interpolation":0.0,
		"target_value":-1.0,
		"current_value":-1.0
	},
	"MouthCornerUpDownLeft": {
		"interpolation":0.0,
		"target_value":-1.0,
		"current_value":-1.0
	},
	"MouthCornerInOutLeft": {
		"interpolation":0.0,
		"target_value":-1.0,
		"current_value":-1.0
	},
	"MouthCornerUpDownRight": {
		"interpolation":0.0,
		"target_value":-1.0,
		"current_value":-1.0
	},
	"MouthCornerInOutRight": {
		"interpolation":0.0,
		"target_value":-1.0,
		"current_value":-1.0
	},
	"MouthOpen": {
		"interpolation":0.0,
		"target_value":-1.0,
		"current_value":-1.0
	},
	"MouthWide": {
		"interpolation":0.0,
		"target_value":-1.0,
		"current_value":-1.0
	},
	"Euler":{
		"interpolation":0.0,
		"target_value":Vector3.ZERO,
		"current_value":Vector3.ZERO
	},
	"Translation":{
		"interpolation":0.0,
		"target_value":Vector3.ZERO,
		"current_value":Vector3.ZERO,
		"calibrate":Vector3.ZERO
	},
	"Quaternion":{
		"interpolation":0.5,
		"target_value":Quaternion.from_euler(Vector3(0,0,0)),
		"current_value":Quaternion.from_euler(Vector3(0,0,0)),
		"calibrate":Quaternion.from_euler(Vector3.ZERO)
	},
	"rightEyeOpen":{
		"interpolation":0.0,
		"target_value":-1.0,
		"current_value":-1.0
	},
	"leftEyeOpen":{
		"interpolation":0.0,
		"target_value":-1.0,
		"current_value":-1.0
	},
	"leftEyeGaze":{
		"interpolation":0.0,
		"target_value":Quaternion.from_euler(Vector3(0,0,0)),
		"current_value":Quaternion.from_euler(Vector3(0,0,0)),
		"calibrate":Quaternion.from_euler(Vector3.ZERO)
	},
	"rightEyeGaze":{
		"interpolation":0.0,
		"target_value":Quaternion.from_euler(Vector3(0,0,0)),
		"current_value":Quaternion.from_euler(Vector3(0,0,0)),
		"calibrate":Quaternion.from_euler(Vector3.ZERO)
	},
	"horizontalLooking":{
		"interpolation":0.0,
		"target_value":0.0,
		"current_value":0.0
	},
	"verticalLooking":{
		"interpolation":0.0,
		"target_value":0.0,
		"current_value":0.0
	},
}

##FPS of the camera in use/ update rate of the face tracking
@export var update_rate:float=24.0
##emitted whenever update_info is run
signal info_updated(new_info)

var OSF_data:Dictionary={}

#func _init(on_obj):
	#create_signals.call_deferred(on_obj)
#func create_signals(on_obj)->void:
	#for feature in features:
		#feature_signals[feature]=Signal(on_obj,StringName("%sUpdated"%feature))
	

func update_info()->void:
	###
	### REGULAR FEATURES
	### 
	for feature in OSF_data["features"]:
		features[feature]["target_value"]=OSF_data["features"][feature]
		if features[feature]["interpolation"]==0.0:
			features[feature]["current_value"]=OSF_data["features"][feature]
	#print(OSF_data["euler"])
	###
	### EULER/HEAD FACE DIRECTION
	###
	#yeah, just use the quaternion and get_euler() if you needto
	#this one just sucks
	#it works, if you need it you can just uncomment it
	#but personally, i disliked it and think it wastes some processing power i could use
	#anywhere else so yeah.
	
	#var OSF_EULER=Vector3(OSF_data["euler"]["x"],OSF_data["euler"]["y"],OSF_data["euler"]["z"])
	#features["Euler"]["target_value"]=OSF_EULER
	#if features["Euler"]["interpolation"]==0.0:
		#features["Euler"]["current_value"]=OSF_EULER
	#else:
		#var cur_val=features["Euler"]["current_value"]
		#var lerp_speed=features["Euler"]["interpolation"]
		#var out_val=Vector3(
			#lerp(cur_val.x,OSF_EULER.x,lerp_speed),
			#lerp(cur_val.y,OSF_EULER.y,lerp_speed),
			#lerp(cur_val.z,OSF_EULER.z,lerp_speed)
		#)
		#features["Euler"]["current_value"]=out_val
	
	
	###
	### QUATERNION/HEAD FACE DIRECTION
	###
	
	var OSF_QUATERNION=Quaternion(OSF_data["quaternion"]["x"],OSF_data["quaternion"]["y"],OSF_data["quaternion"]["z"],OSF_data["quaternion"]["w"])
	OSF_QUATERNION=Quaternion.from_euler(
		OSF_QUATERNION.get_euler()-features["Quaternion"]["calibrate"].get_euler()
	)
	
	features["Quaternion"]["target_value"]=OSF_QUATERNION
	if features["Quaternion"]["interpolation"]==0.0:
		features["Quaternion"]["current_value"]=OSF_QUATERNION
	
	###
	### LEFT/RIGHT EYE OPEN
	###
	var eye_open=[
		OSF_data["leftEyeOpen"],
		OSF_data["rightEyeOpen"]
	]
	features["leftEyeOpen"]["target_value"]=eye_open[0]
	features["rightEyeOpen"]["target_value"]=eye_open[1]
	if features["leftEyeOpen"]["interpolation"]==0.0:
		features["leftEyeOpen"]["current_value"]=eye_open[0]
	if features["rightEyeOpen"]["interpolation"]==0.0:
		features["rightEyeOpen"]["current_value"]=eye_open[1]
	var is_blinking=(eye_open[0]<0.2 and eye_open[1]<0.2)
	features["Blink"]["target_value"]=float(is_blinking)
	if features["Blink"]["interpolation"]==0.0:
		features["Blink"]["current_value"]=float(is_blinking)
	
	
	###
	### EYE GAZE LEFT/RIGHT
	###
	### IF BLINKING, IT WON'T UPDATE TO PREVENT EYES BEING JUMPY
	
	if !is_blinking:
		var points3D=OSF_data["points3D"]
		var rightGaze = -Basis().looking_at(points3D[66]*Vector3(-1,1,1) - points3D[68]*Vector3(-1,1,1)).get_euler();
		var leftGaze = -Basis().looking_at(points3D[67]*Vector3(-1,1,1) - points3D[69]*Vector3(-1,1,1)).get_euler();
		rightGaze=Quaternion.from_euler(
				rightGaze-features["rightEyeGaze"]["calibrate"].get_euler()
		)
		leftGaze=Quaternion.from_euler(
				leftGaze-features["leftEyeGaze"]["calibrate"].get_euler()
		)
		features["leftEyeGaze"]["target_value"]=leftGaze
		features["rightEyeGaze"]["target_value"]=rightGaze
		if features["leftEyeGaze"]["interpolation"]==0.0:
			features["leftEyeGaze"]["current_value"]=leftGaze
		if features["rightEyeGaze"]["interpolation"]==0.0:
			features["rightEyeGaze"]["current_value"]=rightGaze
		
		var gaze_average=(leftGaze.get_euler()+rightGaze.get_euler())*0.5
		var gaze_direction=Vector2(gaze_average.y*0.31831,gaze_average.x*0.31831)
		
		features["horizontalLooking"]["target_value"]=gaze_direction.x
		features["verticalLooking"]["target_value"]=gaze_direction.y
		if features["horizontalLooking"]["interpolation"]==0.0:
			features["horizontalLooking"]["current_value"]=gaze_direction.x
		if features["verticalLooking"]["interpolation"]==0.0:
			features["verticalLooking"]["current_value"]=gaze_direction.y
		
		
		
	
	
	
	
	
	###
	### TRANSLATION/HEAD POSITION
	###
	#it tracks between your ears since this normally wonr work by just getting
	#the translation data. for some reason it is always zero by default
	#so this method is functional and more controlled personally
	
	#var head_pos=Vector3(
		#OSF_data["translation"]["x"],
		#OSF_data["translation"]["y"],
		#OSF_data["translation"]["z"]
	#)
	var head_pos=OSF_data["points3D"][0]
	
	
	
	features["Translation"]["target_value"]=head_pos
	if features["Translation"]["interpolation"]==0.0:
		features["Translation"]["current_value"]=head_pos
	
	
	
	
	
	
	
	
	info_updated.emit(features)




func _update_features(delta:float)->void:
	delta=60*delta
	### GENERAL FACE
	for feature in features:
		if not features[feature]["current_value"] is float:continue
		if features[feature]["interpolation"]>0.0:
			var change_rate=features[feature]["interpolation"]
			features[feature]["current_value"]=lerp(features[feature]["current_value"],features[feature]["target_value"],change_rate*delta)
	
	
	
	### HEAD POSITON
	if features["Translation"]["interpolation"]>0.0:
		var cur_value=features["Translation"]["current_value"]
		features["Translation"]["current_value"].move_towards(
			features["Translation"]["target_value"],features["Translation"]["interpolation"]*delta
		)
	### EYES
	if features["rightEyeOpen"]["interpolation"]>0.0:
		var cur_val=features["rightEyeOpen"]["current_value"]
		features["rightEyeOpen"]["current_value"]=lerp(cur_val,features["rightEyeOpen"]["target_value"],features["rightEyeOpen"]["interpolation"]*delta)
	if features["leftEyeOpen"]["interpolation"]>0.0:
		var cur_val=features["leftEyeOpen"]["current_value"]
		features["leftEyeOpen"]["current_value"]=lerp(cur_val,features["leftEyeOpen"]["target_value"],features["leftEyeOpen"]["interpolation"]*delta)
	### HEAD ROTATIONS
	if features["Quaternion"]["interpolation"]>0.0:
		var cur_val=features["Quaternion"]["current_value"]
		var lerp_speed=features["Quaternion"]["interpolation"]
		features["Quaternion"]["current_value"]=cur_val.slerp(features["Quaternion"]["target_value"],lerp_speed*delta)
	
	### EYE GAZE ROTATIONS
	if features["leftEyeGaze"]["interpolation"]>0.0:
		var cur_val=features["leftEyeGaze"]["current_value"]
		var lerp_speed=features["leftEyeGaze"]["interpolation"]
		features["leftEyeGaze"]["current_value"]=cur_val.slerp(features["leftEyeGaze"]["target_value"],lerp_speed*delta)
	if features["rightEyeGaze"]["interpolation"]>0.0:
		var cur_val=features["rightEyeGaze"]["current_value"]
		var lerp_speed=features["rightEyeGaze"]["interpolation"]
		features["rightEyeGaze"]["current_value"]=cur_val.slerp(features["rightEyeGaze"]["target_value"],lerp_speed*delta)
	#for feature in feature_signals:
		#feature_signals[feature].emit(features[feature]["current_value"])
	

##recalibrates values so that current situation is forward/normal
func calibrate()->void:
	var cali=features["Quaternion"]["calibrate"]
	var target=features["Quaternion"]["target_value"]
	features["Quaternion"]["calibrate"]=Quaternion.from_euler(
		cali.get_euler()+target.get_euler()
	)
	cali=features["leftEyeGaze"]["calibrate"]
	target=features["leftEyeGaze"]["target_value"]
	features["leftEyeGaze"]["calibrate"]=Quaternion.from_euler(
		cali.get_euler()+target.get_euler()
	)
	cali=features["rightEyeGaze"]["calibrate"]
	target=features["rightEyeGaze"]["target_value"]
	features["rightEyeGaze"]["calibrate"]=Quaternion.from_euler(
		cali.get_euler()+target.get_euler()
	)
	


func get_storage_dictionary()->Dictionary:
	var output:Dictionary={}
	for value in features:
		output[value]=features[value].duplicate()
		output[value].erase("target_value")
		output[value].erase("current_value")
	
	return output
func load_storage_dictionary(input:Dictionary)->void:
	for value in input:
		if not features.has(value):continue
		if features[value].has("calibrate"):
			features[value]["calibrate"]=input[value]["calibrate"]
		features[value]["interpolation"]=input[value]["interpolation"]


func calibrateAll()->void:
	for feature in features:
		calibrateFeature(feature)
		
func calibrateFeature(feature:String)->void:
	if !features[feature].has("calibrate"):return
	var feature_type=typeof(features[feature]["calibrate"])
	match feature_type:
		TYPE_QUATERNION:features[feature]["calibrate"]=Quaternion.from_euler(
				features[feature]["target_value"].get_euler()+features[feature]["calibrate"].get_euler()
			)
		TYPE_VECTOR3:features[feature]["calibrate"]=features[feature]["target_value"]+features[feature]["calibrate"]
		TYPE_VECTOR2:features[feature]["calibrate"]=features[feature]["target_value"]+features[feature]["calibrate"]
		TYPE_FLOAT:features[feature]["calibrate"]=features[feature]["target_value"]+features[feature]["calibrate"]
		TYPE_INT:features[feature]["calibrate"]=features[feature]["target_value"]+features[feature]["calibrate"]

func calibrateFeatures(feature_names:Array)->void:
	for feature_name in feature_names:calibrateFeature(feature_name)


func ConnectInfoToSignal(onObject):
	onObject.onDataPackage.connect(update_info)
	
	OSF_data=onObject.getPackage();
