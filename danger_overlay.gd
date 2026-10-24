class_name DangerOverlay extends CanvasLayer


@onready var overlay_rect: ColorRect = $OverlayRect
@onready var overlay_material: ShaderMaterial = $OverlayRect.material

func _enter_tree() -> void:
	Globals.danger_overlay = self

func set_danger(value: float) -> void:
	var mat = overlay_material
	if not mat and has_node("OverlayRect"):
		mat = $OverlayRect.material as ShaderMaterial

	if mat:
		mat.set_shader_parameter("danger", clampf(value, 0.0, 1.0))
		print("material found")
	else:
		print("no material found on OverlayRect yet")
