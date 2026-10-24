
extends Camera2D
class_name CutsceneCamera

func pan_to(target_position: Vector2, duration: float) -> void:
	make_current()
	var tween := create_tween()
	tween.tween_property(self, "global_position", target_position, duration)
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
