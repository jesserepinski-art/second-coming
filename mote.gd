extends Node2D

signal finished(layer)

const FAR := 0
const MID := 1
const NEAR := 2

var layer:int

var velocity := Vector2.ZERO

var wander_speed := 0.0
var wander_amount := 0.0

var base_alpha := 0.0

var pulse_speed := 0.0
var pulse_offset := 0.0

var age := 0.0

@onready var sprite := $Sprite2D


func setup(new_layer:int,pos:Vector2):

	layer = new_layer
	position = pos

	match layer:

		FAR:

			scale = Vector2.ONE * randf_range(0.25,0.45)

			velocity = Vector2(
				randf_range(-6,-1),
				randf_range(-20,-12)
			)

			base_alpha = randf_range(0.03,0.06)

		MID:

			scale = Vector2.ONE * randf_range(0.45,0.75)

			velocity = Vector2(
				randf_range(-8,2),
				randf_range(-32,-22)
			)

			base_alpha = randf_range(0.05,0.09)

		NEAR:

			scale = Vector2.ONE * randf_range(0.8,1.2)

			velocity = Vector2(
				randf_range(-10,4),
				randf_range(-45,-32)
			)

			base_alpha = randf_range(0.1,0.5)

	wander_speed = randf_range(0.3,0.8)
	wander_amount = randf_range(3.0,10.0)

	pulse_speed = randf_range(0.3,0.8)
	pulse_offset = randf() * TAU

	var colors = [
		Color("fff7eb"),
		Color("ffe9dd"),
		Color("fff0d8")
	]

	sprite.modulate = colors.pick_random()
	sprite.modulate.a = base_alpha

	sprite.rotation = randf_range(-0.25,0.25)


func _process(delta):

	age += delta

	position += velocity * delta

	position.x += sin(age * wander_speed) * wander_amount * delta

	sprite.modulate.a = base_alpha + sin(age * pulse_speed + pulse_offset) * 0.015

	if position.y < -20:
		finished.emit(layer)
		queue_free()
