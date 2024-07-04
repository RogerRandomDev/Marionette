extends Window

# TODO (Tim Yuen) Godot still can't infer types correctly, so they have to be casted

@onready var FaceHandler=$OpenSeeFaceHandler


## Redundant keys for quick access
const OSF_OPTIONS := {
	"IP": {
		"display_name": "IP",
		"flag": "--ip",
		"config_mapping": "ip",
		"hint": "The IP address for sending tracking data."
	},
	"Port": {
		"display_name": "Port",
		"flag": "--port",
		"config_mapping": "port",
		"hint": "The port for sending tracking data."
	},
	"List Cameras": {
		"display_name": "List Cameras",
		"flag": "--list-cameras",
		"config_mapping": "list_cameras",
		"hint": "Set to 1 to list the available cameras and quit. Set to 2 or higher to output only the camera names.",
		"windows_only": true
	},
	"List DCaps": {
		"display_name": "List DCaps",
		"flag": "--list-dcaps",
		"config_mapping": "list_dcaps",
		"hint": "Set to -1 to list all cameras and their available capabilities. Set this to a camera ID to list that camera's capabilities.",
		"windows_only": true
	},
	"DCap": {
		"display_name": "DCap",
		"flag": "--dcap",
		"config_mapping": "dcap",
		"hint": "Set which device capability line to use or -1 to use the default camera settings. FPS will still need to be set separately.",
		"windows_only": true
	},
	"Blackmagic": {
		"display_name": "Blackmagic",
		"flag": "--blackmagic",
		"config_mapping": "blackmagic",
		"hint": "Set to 1 to enable Blackmagic device support, if applicable.",
		"windows_only": true
	},
	"Width": {
		"display_name": "Width",
		"flag": "--width",
		"config_mapping": "width",
		"hint": "The RGB width."
	},
	"Height": {
		"display_name": "Height",
		"flag": "--height",
		"config_mapping": "height",
		"hint": "The raw RGB height."
	},
	"Max Threads": {
		"display_name": "Max Threads",
		"flag": "--max-threads",
		"config_mapping": "max_threads",
		"hint": "The maximum number of threads to use. MORE THREADS DOES _NOT_ MEAN MORE PERFORMANCE."
	},
	"Threshold": {
		"display_name": "Threshold",
		"flag": "--threshold",
		"config_mapping": "threshold",
		"hint": "The minimum confidence threshold for face tracking."
	},
	"Detection Threshold": {
		"display_name": "Detection Threshold",
		"flag": "--detection-threshold",
		"config_mapping": "detection_threshold",
		"hint": "The minimum confidence interval for face detection."
	},
	"Visualize": {
		"display_name": "Visualize",
		"flag": "--visualize",
		"config_mapping": "visualize",
		"hint": "Set to 1 to visualize the tracking results, set to 2 to also show face ids, set to 3 to add confidence values, and set to 4 to add numbers to the point display."
	},
	"FPS": {
		"display_name": "FPS",
		"flag": "--video-fps",
		"config_mapping": "fps",
		"hint": "Sets Video FPS. 12 recommended."
	},
	"PnP Points": {
		"display_name": "PnP Points",
		"flag": "--pnp-points",
		"config_mapping": "pnp_points",
		"hint": "Set to 1 to add the 3D fitting points to the visualization."
	},
	"Silent": {
		"display_name": "Silent",
		"flag": "--silent",
		"config_mapping": "silent",
		"hint": "Set to 1 to prevent console text output."
	},
	"Discard After": {
		"display_name": "Discard After",
		"flag": "--discard-after",
		"config_mapping": "discard_after",
		"hint": "How long the tracker should keep looking for lost faces."
	},
	"Max Feature Updates": {
		"display_name": "Max Feature Updates",
		"flag": "--max-feature-updates",
		"config_mapping": "max_feature_updates",
		"hint": "The number of seconds after which feature min/max/medium values will no longer be updated once a face has been detected."
	},
	"Raw RGB": {
		"display_name": "Raw RGB",
		"flag": "--raw-rgb",
		"config_mapping": "raw_rgb",
		"hint": "When set, raw RGB frames of the size given from Width and Height are read from standard input instead of reading a video."
	},
	"Log Data": {
		"display_name": "Log Data",
		"flag": "--log-data",
		"config_mapping": "log_data",
		"hint": "A filename where tracking data will be logged."
	},
	"Model": {
		"display_name": "Model",
		"flag": "--model",
		"config_mapping": "model",
		"hint": "The tracking model to use. Higher numbers are models with better tracking quality but slower speed except for model 4 which is wink optimized. Models 1 and 0 tend to be too rigid for expression and blink detection. Model -2 is roughly equivalent to model 1 but faster. Model -3 is between models 0 and -1."
	},
	"Gaze Tracking": {
		"display_name": "Gaze Tracking",
		"flag": "--gaze-tracking",
		"config_mapping": "gaze_tracking",
		"hint": "Set to 1 to enable gaze tracking which makes things slightly slower."
	},
	"Use DShowCapture": {
		"display_name": "Use DShowCapture",
		"flag": "--use-dshowcapture",
		"config_mapping": "use_dshowcapture",
		"hint": "Set to 1 to use libdshowcapture instead of OpenCV",
		"windows_only": true
	}
}
class OsfOption extends HBoxContainer:
	var _label: Label = null
	var _line_edit: LineEdit = null
	var _element: Control = null
	
	func _init(
		option_name: String,
		option_value: Variant,
		callback: Callable,
		hint: String,
		element_type: int
	) -> void:
		_label = Label.new()
		_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_label.text = option_name
		
		if element_type == TYPE_STRING:
			_element = LineEdit.new()
			_element.text = option_value
			_element.text_changed.connect(callback)
		else:
			_element = CheckBox.new()
			_element.button_pressed = option_value
			_element.toggled.connect(callback)
		
		_element.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		add_child(_label)
		add_child(_element)
		
		if not hint.is_empty():
			self.tooltip_text = hint
			_label.tooltip_text = hint
			_element.tooltip_text = hint
	
	func option_name() -> String:
		return _label.text
	
	func option_value() -> Variant:
		return _element.text if _element is LineEdit else _element.button_pressed

var _config: Config = null
var _is_windows := false
var _use_binary := true
var _tracker_pid := -1

@onready
var _status := %Status as RichTextLabel

@onready
var _binary_path := %BinaryPath as LineEdit

@onready
var _python_path := %PythonPath as LineEdit
@onready
var _osf_path := %OsfPath as LineEdit

@onready
var _osf_options := %OsfOptions as VBoxContainer

#-----------------------------------------------------------------------------#
# Builtin functions
#-----------------------------------------------------------------------------#

func _ready() -> void:
	join_tracker()
	_config = _read_config()
	#loads into globals the face handler
	Globals.FaceHandler=$OpenSeeFaceHandler
	
	
	_is_windows = OS.get_name().to_lower() == "windows"
	
	var run_button := %Run as Button
	run_button.pressed.connect(func() -> void:
		if run_button.text!="Run":
			%Run.text="Run"
			if _tracker_pid>0:OS.kill(_tracker_pid)
			return
		
		var exe_path := ""
		var run_options := []
		
		if _use_binary:
			if _config.binary_path.is_empty():
				self._update_status("No OpenSeeFace binary configured")
				return
			
			exe_path = _config.binary_path
			
		else:
			if _config.python_path.is_empty():
				self._update_status("No Python binary configured")
				return
			elif _config.osf_path.is_empty():
				self._update_status("No OpenSeeFace folder configured")
				return
			
			exe_path = _config.python_path
			run_options.push_back("%s/facetracker.py" % _config.osf_path)
			
		if not FileAccess.file_exists(exe_path):
			self._update_status("%s does not exist" % exe_path)
			return
		
		if not _use_binary and run_options.front() != null and not FileAccess.file_exists(run_options.front()):
			return
		
		for child in _osf_options.get_children():
			var val = child.option_value()
			match typeof(val):
				TYPE_STRING:
					if val.is_empty():
						continue
				TYPE_BOOL:
					if not val:
						continue
			run_options.push_back(OSF_OPTIONS[child.option_name()].flag)
			run_options.push_back(val)
			
		#var option_count=len(run_options)
		#for i in range(1,ceil(option_count/2)):
			#var option_i=run_options[i+1]
			#run_options[i]+="="+option_i
			#run_options.remove_at(i+1)
		run_options.push_back("-M")
		#print(run_options)
		
		var pid := OS.create_process(exe_path, run_options, true)
		if pid < 0:
			self._update_status("Unable to start tracker")
		else:
			_tracker_pid = pid
			%Run.text="Stop"
	)
	
	var binary_options := %BinaryOptions as VBoxContainer
	var python_options := %PythonOptions as VBoxContainer
	binary_options.show()
	python_options.hide()
	
	%ChooseBinary.pressed.connect(func() -> void:
		var popup := _show_file_dialog()
		popup.file_selected.connect(func(path: String) -> void:
			_binary_path.text = path
			_config.binary_path = path
		)
	)
	_binary_path.text = _config.binary_path
	
	%ChoosePython.pressed.connect(func() -> void:
		var popup := _show_file_dialog()
		popup.file_selected.connect(func(path: String) -> void:
			_python_path.text = path
			_config.python_path = path
		)
	)
	_python_path.text = _config.python_path
	%ChooseOsf.pressed.connect(func() -> void:
		var popup := _show_file_dialog(FileDialog.FILE_MODE_OPEN_DIR)
		popup.dir_selected.connect(func(path: String) -> void:
			_osf_path.text = path
			_config.osf_path = path
		)
	)
	_osf_path.text = _config.osf_path
	
	for data in OSF_OPTIONS.values():
		if data.get("windows_only", false) and not _is_windows:
			continue
		var option := OsfOption.new(
			data.display_name,
			_config.get(data.config_mapping),
			func(value: Variant) -> void:
				_config.set(data.config_mapping, value),
			data.get("hint", ""),
			data.get("type", TYPE_STRING)
		)
		
		_osf_options.add_child(option)
	
	%Recalibrate.pressed.connect(
		func():
			var _data=$OpenSeeFaceHandler._dataInfo
			_data.calibrateAll()
	)
	
	
	_update_status("Ready!")

func _exit_tree() -> void:
	_write_config(_config)
	
	# Technically this should be -1, but PID 0 is usually the system root process
	# On Linux, I'm pretty sure all PIDs must be greater than 1000
	if _tracker_pid > 0:
		OS.kill(_tracker_pid)

#-----------------------------------------------------------------------------#
# Private functions
#-----------------------------------------------------------------------------#

func _update_status(text: String) -> void:
	_status.text = "[right][rainbow][wave]%s[/wave][/rainbow][/right]" % text

func _show_file_dialog(file_mode: int = FileDialog.FILE_MODE_OPEN_FILE) -> FileDialog:
	var popup := FileDialog.new()
	popup.file_mode = file_mode
	popup.access = FileDialog.ACCESS_FILESYSTEM
	
	add_child(popup)
	popup.popup_centered_ratio(0.5)
	
	popup.close_requested.connect(func() -> void:
		popup.queue_free()
	)
	popup.visibility_changed.connect(func() -> void:
		popup.close_requested.emit()
	)
	
	return popup

static func _read_config() -> Config:
	var config: Resource = ResourceLoader.load(Config.SAVE_PATH, "tres")
	if config == null or not config is Config:
		print("Unable to load config, using new config")
		config = Config.new()
	
	return config as Config

static func _write_config(config: Config) -> void:
	if ResourceSaver.save(config, Config.SAVE_PATH, ResourceSaver.FLAG_CHANGE_PATH) != OK:
		printerr("Unable to write config")

#-----------------------------------------------------------------------------#
# Public functions
#-----------------------------------------------------------------------------#
var run_peer:bool=false
var udp_socket := PacketPeerUDP.new()

func join_tracker():
	$OpenSeeFaceHandler.startServer()
	
