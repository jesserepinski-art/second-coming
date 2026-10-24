extends StaticBody2D


@export var trigger_switch: PressableSwitch

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var opened := false

func _ready() -> void:
	if trigger_switch:
		trigger_switch.activated.connect(_on_switch_activated)

		if trigger_switch.used:
			_set_open_state(true)

func _on_switch_activated() -> void:
	if opened:
		return
	_set_open_state(true)

func _set_open_state(is_open: bool) -> void:
	opened = is_open
	collision_shape.set_deferred("disabled", is_open)

	if sprite:
		sprite.play("open" if is_open else "closed")
