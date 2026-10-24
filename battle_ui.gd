extends MarginContainer

var idle_tween: Tween

func _ready() -> void:
	start_idle()

func start_idle() -> void:
	if idle_tween:
		idle_tween.kill()

	pivot_offset = size / 2.0

	idle_tween = create_tween()
	idle_tween.set_loops()

	idle_tween.parallel().tween_property(
		self,
		"scale",
		Vector2(1.008, 1.008),
		2.8
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	idle_tween.parallel().tween_property(
		self,
		"rotation_degrees",
		0.15,
		2.8
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	idle_tween.parallel().tween_property(
		self,
		"scale",
		Vector2.ONE,
		2.8
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	idle_tween.parallel().tween_property(
		self,
		"rotation_degrees",
		-0.15,
		2.8
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	idle_tween.tween_property(
		self,
		"rotation_degrees",
		0.0,
		2.8
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
