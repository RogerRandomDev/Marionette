extends Node
class_name OpenSeeFaceHandler

@export var listenPort: int = 11572
@export var listenHost: String = "127.0.0.1"
@export var points = 68
@export var started = false:
	set=_onStarted
var udpServerComponent: UDPServer
var _isStarted = false
var _dataInfo


signal onDataPackage

func _onStarted(_newVal):
	if _isStarted == false:
		started = false
	else:
		started = true


func startServer():
	if !udpServerComponent:
		udpServerComponent = UDPServer.new()
		var _err = udpServerComponent.listen(listenPort,listenHost)
		print_debug("opened UDP server: %s:%s" % [listenHost,listenPort])
	
	started = true
	_isStarted = true
	#var calibrate_on_ready=(
		#func(package,own_method):
			#onDataPackage.disconnect(own_method)
			#if _dataInfo:_dataInfo.calibrateAll()
	#)
	#onDataPackage.connect(calibrate_on_ready.bind(calibrate_on_ready))
	
	

func _ready():
	started = false
	_isStarted = false
	_dataInfo=load("res://openseeface/DataInfo.gd").new(self)
	onDataPackage.connect(_dataInfo.update_info)
	
	get_tree().current_scene.world_control_interface.shapekeys_window.load_feature_names(_dataInfo.features.keys())
	


func _physics_process(_delta):
	if _dataInfo:_dataInfo._update_features(_delta)
	if _isStarted == false:
		return
		
	# poll connections
	var _poll = udpServerComponent.poll()

	# new udp transfer available?
	if udpServerComponent.is_connection_available():
		
		# Get udp message from openSeeFace
		var conn = udpServerComponent.take_connection()
		var data: PackedByteArray = conn.get_packet()
		conn.close()

		# process data, prepare for signal
		var dataPackage := {
			"time": -1,
			"id": -1,
			"cam": {
				"x": -1,
				"y": -1
			},
			"rightEyeOpen": -1,
			"leftEyeOpen": -1,
			"3d": -1,
			"fitError": -1,
			"quaternion": {
				"x": -1,
				"y": -1,
				"z": -1,
				"w": -1
			},
			"euler": {
				"x": -1,
				"y": -1,
				"z": -1
			},
			"translation": {
				"x": -1,
				"y": -1,
				"z": -1
			},
			"confidence": [],
			"points": [],
			"points3D": [],
			"features": {
				"EyeLeft": -1,
				"EyeRight": -1,
				"EyeBrowSteepnessLeft": -1,
				"EyeBrowUpDownLeft": -1,
				"EyeBrowQuirkLeft": -1,
				"EyeBrowSteepnessRight": -1,
				"EyeBrowUpDownRight": -1,
				"EyeBrowQuirkRight": -1,
				"MouthCornerUpDownLeft": -1,
				"MouthCornerInOutLeft": -1,
				"MouthCornerUpDownRight": -1,
				"MouthCornerInOutRight": -1,
				"MouthOpen": -1,
				"MouthWide": -1
			}
		}

		var streamBuff: StreamPeerBuffer = StreamPeerBuffer.new()
		var streamPos = 0
		streamBuff.data_array = data.slice(streamPos,8)
		streamPos = streamPos + 8
		
		dataPackage["time"] = streamBuff.get_double()
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		
		dataPackage["id"] = streamBuff.get_32()
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		
		dataPackage["cam"]["x"] = streamBuff.get_float()
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		
		dataPackage["cam"]["y"] = streamBuff.get_float()
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		
		dataPackage["rightEyeOpen"] = streamBuff.get_float()
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		
		dataPackage["leftEyeOpen"] = streamBuff.get_float()
		streamBuff.data_array = data.slice(streamPos,streamPos+1)
		streamPos = streamPos + 1
		
		dataPackage["3d"] = streamBuff.get_8()
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		
		dataPackage["fitError"] = streamBuff.get_float()
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		
		dataPackage["quaternion"]["x"] = streamBuff.get_float()
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		
		dataPackage["quaternion"]["y"] = streamBuff.get_float()
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		
		dataPackage["quaternion"]["z"] = streamBuff.get_float()
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		
		dataPackage["quaternion"]["w"] = streamBuff.get_float()
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		
		dataPackage["euler"]["x"] = deg_to_rad(streamBuff.get_float())
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		
		dataPackage["euler"]["y"] = deg_to_rad(streamBuff.get_float())
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		
		dataPackage["euler"]["z"] = deg_to_rad(streamBuff.get_float())
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		
		dataPackage["translation"]["x"] = streamBuff.get_float()
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		
		dataPackage["translation"]["y"] = streamBuff.get_float()
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		
		dataPackage["translation"]["z"] = streamBuff.get_float()

		#print("time: %d | id %d | cam x: %d y: %d | 3d?: %d | fitError: %d | quaternion: %d/%d/%d/%d | euler: %d/%d/%d | translation: %d/%d/%d" % [dataPackage["time"],dataPackage["id"],dataPackage["cam"]["x"],dataPackage["cam"]["y"],dataPackage["3d"],dataPackage["fitError"], dataPackage["quaternion"]["x"], dataPackage["quaternion"]["y"],dataPackage["quaternion"]["z"],dataPackage["quaternion"]["w"],dataPackage["euler"]["x"],dataPackage["euler"]["y"],dataPackage["euler"]["z"],dataPackage["translation"]["x"],dataPackage["translation"]["y"],dataPackage["translation"]["z"] ])

		for _i in range(points):
			streamBuff.data_array = data.slice(streamPos,streamPos+4)
			streamPos = streamPos + 4
			dataPackage["confidence"].append(streamBuff.get_float())
		
		
		for _i in range(points):
			streamBuff.data_array = data.slice(streamPos,streamPos+4)
			streamPos = streamPos + 4
			var a = streamBuff.get_float()
			streamBuff.data_array = data.slice(streamPos,streamPos+4)
			streamPos = streamPos + 4
			var b = streamBuff.get_float()
			var v = Vector2(a,b)
			dataPackage["points"].append(v)

		
		for _i in range(points+2):
			streamBuff.data_array = data.slice(streamPos,streamPos+4)
			streamPos = streamPos + 4
			var a = streamBuff.get_float()
			streamBuff.data_array = data.slice(streamPos,streamPos+4)
			streamPos = streamPos + 4
			var b = streamBuff.get_float()
			streamBuff.data_array = data.slice(streamPos,streamPos+4)
			streamPos = streamPos + 4
			var c = streamBuff.get_float()
			dataPackage["points3D"].append(Vector3(a,b,c))
			
		
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		dataPackage["features"]["EyeLeft"] = streamBuff.get_float()
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		dataPackage["features"]["EyeRight"] = streamBuff.get_float()
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		dataPackage["features"]["EyeBrowSteepnessLeft"] = streamBuff.get_float()
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		dataPackage["features"]["EyeBrowUpDownLeft"] = streamBuff.get_float()
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		dataPackage["features"]["EyeBrowQuirkLeft"] = streamBuff.get_float()
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		dataPackage["features"]["EyeBrowSteepnessRight"] = streamBuff.get_float()
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		dataPackage["features"]["EyeBrowUpDownRight"] = streamBuff.get_float()
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		dataPackage["features"]["EyeBrowQuirkRight"] = streamBuff.get_float()
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		dataPackage["features"]["MouthCornerUpDownLeft"] = streamBuff.get_float()
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		dataPackage["features"]["MouthCornerInOutLeft"] = streamBuff.get_float()
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		dataPackage["features"]["MouthCornerUpDownRight"] = streamBuff.get_float()
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		dataPackage["features"]["MouthCornerInOutRight"] = streamBuff.get_float()
		streamBuff.data_array = data.slice(streamPos,streamPos+4)
		streamPos = streamPos + 4
		dataPackage["features"]["MouthOpen"] = streamBuff.get_float()
		streamBuff.data_array = data.slice(streamPos,streamPos+3)
		streamPos = streamPos + 4
		dataPackage["features"]["MouthWide"] = streamBuff.get_float()
		
		emit_signal("onDataPackage", dataPackage)
