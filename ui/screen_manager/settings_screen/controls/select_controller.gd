extends OptionButton

@export var options: ControlsContents

var currently_disabled: bool


func _ready():
	_update_button()

	Input.joy_connection_changed.connect(_update_list)


func _update_list(device_port: int, connected: bool):
	var joypad_name: String = Input.get_joy_name(device_port)
	var saved_controller: String = LocalSettings.load_setting("Controller (Player: %d)" % options.player, "name", "")

	if connected:
		add_item(joypad_name, device_port)
	else:
		remove_item(get_item_index(device_port))

	_update_button()

	for id in Input.get_connected_joypads():
		if saved_controller == Input.get_joy_name(id):
			selected = get_item_index(id)


func _check_none_connected() -> bool:
	return Input.get_connected_joypads().is_empty()


func _update_button():
	var none_connected: bool = _check_none_connected()

	disabled = none_connected

	if none_connected and not currently_disabled:
		currently_disabled = true
		add_item("No Controller(s) Detected", 0)
	elif currently_disabled and not none_connected:
		currently_disabled = false
		remove_item(0)


func _on_item_selected(index):
	var joypad_name: String = Input.get_joy_name(index)

	LocalSettings.change_setting("Controller (Player: %d)" % options.player, "name", joypad_name)

	options.device_port = index
	options.update_buttons()
