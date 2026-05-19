extends StaticBody3D

signal hovered()
signal unhovered()

var _default_material: StandardMaterial3D
var _hovered_material: StandardMaterial3D
var _mesh_instance: MeshInstance3D


func _ready() -> void:
	_mesh_instance = $MeshInstance3D
	_default_material = StandardMaterial3D.new()
	_default_material.albedo_color = Color.GRAY
	_hovered_material = StandardMaterial3D.new()
	_hovered_material.albedo_color = Color.YELLOW
	_mesh_instance.material_override = _default_material

	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exit)


func set_highlighted(on: bool) -> void:
	if on:
		_mesh_instance.material_override = _hovered_material
	else:
		_mesh_instance.material_override = _default_material


func _on_mouse_enter() -> void:
	hovered.emit()
	set_highlighted(true)


func _on_mouse_exit() -> void:
	unhovered.emit()
	set_highlighted(false)
