extends PointLight2D

var colors := [
	Color(0.1, 0.1, 0.8),
	Color(0.5, 0.1, 0.7),
	Color(0.4, 1.0, 0.2),
	Color(0.2, 0.9, 0.9),
]

@export var shuffle_interval := 1.5

func _ready() -> void:
	_shuffle_color()

func _shuffle_color() -> void:
	var target: Color = colors.pick_random()
	var tween := create_tween()
	tween.tween_property(self, "color", target, shuffle_interval * 0.5)
	await get_tree().create_timer(shuffle_interval).timeout
	_shuffle_color()
