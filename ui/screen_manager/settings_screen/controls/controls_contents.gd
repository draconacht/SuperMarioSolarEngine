class_name ControlsContents
extends VBoxContainer
## Functionality for the contents of the controls menu.

@export var player: int = 0

@export_category(&"Motion References")
@export var motion_toggle: Button

@export_category(&"Rumble References")
@export var rumble_menu_toggle: Button
@export var rumble_menu: Control
@export var rumble_icon: TextureRect
@export var rumble_progress: ColorRect
@export var rumble_modes: HBoxContainer

var rumble_names: Array[StringName]

@export_category(&"Bindings References")
@export var bindings_list: VBoxContainer

@export var fake_label: Control
@export var header_keyboard: Label
@export var header_controller: Label

var device_port: int = 0

@onready var bindings_children: Array[Node] = bindings_list.get_children()


func _ready():
	update_buttons()

	_update_header()

	var saved_controller: String = LocalSettings.load_setting("Controller (Player: %d)" % player, "name", "")

	for id in Input.get_connected_joypads():
		if saved_controller == Input.get_joy_name(id):
			device_port = id

	# All the rumble stuff down here
	_update_rumble_visible(false)

	for mode in rumble_modes.get_children():
		if mode is Button:
			var mode_name = mode.name

			mode.pressed.connect(_update_rumble.bind(mode_name))
			rumble_names.append(mode_name)

	var mode_count = rumble_names.size() - 1

	rumble_progress.size_flags_stretch_ratio = mode_count
	_set_rumble_shader_param(&"segment_count", mode_count)


## Setup / update the bind buttons if [member device_port] was updated.
func update_buttons():
	for bind in bindings_list.get_children():
		bind.setup_buttons(device_port, player)


func _update_motion_toggle(toggled_on: bool):
	var suffix: String

	if toggled_on:
		suffix = "ENABLED"
	else:
		suffix = "DISABLED"

	motion_toggle.text = "Motion Controls: " + suffix


## Updates the visibility of the rumble menu toggle button according to its state.
func _update_rumble_visible(menu_visible: bool):
	var prefix: String

	if menu_visible:
		prefix = "Close"
	else:
		prefix = "Open"

	rumble_menu_toggle.text = prefix + " Rumble Settings"
	rumble_menu.visible = menu_visible


## Updates the rumble setting the relating graphics.
func _update_rumble(strength: StringName):
	var strength_id: int
	var strength_count = rumble_names.size()
	var icon_texture = rumble_icon.texture as AtlasTexture

	strength_id = rumble_names.find(strength)

	# Update graphics
	icon_texture.region.position.x = icon_texture.region.size.x * strength_id
	_set_rumble_shader_param(&"value", strength_id)

	# Start a vibration
	var magnitude: float = 1.0 / strength_count * strength_id

	Input.start_joy_vibration(device_port, magnitude, magnitude, 0.1)

	# Save the value to LocalSettings
	LocalSettings.change_setting("Rumble (Player: %d)" % player, "Strength", strength)


func _set_rumble_shader_param(parameter: StringName, value: Variant):
	var rumble_material = rumble_progress.material as ShaderMaterial

	rumble_material.set_shader_parameter(parameter, value)


## Updates the bindings header for the bindings to fit correctly.
func _update_header():
	var biggest_w: float

	for child in bindings_children:
		biggest_w = max(biggest_w, child.get_label_w())

	for child in bindings_children:
		child.set_label_w(biggest_w)

	fake_label.custom_minimum_size.x = biggest_w


func _on_rumble_menu_toggle_toggled(toggled_on):
	_update_rumble_visible(toggled_on)


func _on_motion_toggle_toggled(toggled_on):
	_update_motion_toggle(toggled_on)
