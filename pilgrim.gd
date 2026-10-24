extends Node2D

signal finished(layer)

const FAR := 0
const MID := 1
const NEAR := 2

var layer:int
var direction := -1

var speed := 5.0
var max_alpha := 0.5

var age := 0.0
var start_y := 0.0

@onready var sprite:Sprite2D = $Sprite2D


func setup(new_layer:int,new_direction:int,pos:Vector2):
	var bob_height := 0.0
	var bob_speed := 0.0
	var bob_offset := 0.0
	bob_height = randf_range(0.5, 2.0)
	bob_speed = randf_range(0.8, 1.2)
	bob_offset = randf_range(0.0, TAU)

	layer = new_layer
	direction = new_direction

	position = pos

	match layer:

		FAR:
			scale = Vector2.ONE * randf_range(0.40, 0.50)
			speed = randf_range(6.0, 8.0)
			max_alpha = randf_range(0.04, 0.08)

		MID:
			scale = Vector2.ONE * randf_range(0.65, 0.75)
			speed = randf_range(10.0, 13.0)
			max_alpha = randf_range(0.10, 0.15)

		NEAR:
			scale = Vector2.ONE * randf_range(0.95, 1.05)
			speed = randf_range(16.0, 20.0)
			max_alpha = randf_range(0.18, 0.25)
	sprite.flip_h = direction > 0


func _ready():

	start_y = position.y

	modulate.a = 0

	age = randf_range(0.0,2.0)


func _process(delta):

	age += delta
	var bob_height := 0.0
	var bob_speed := 0.0
	var bob_offset := 0.0
	var drift := 1.0 + sin(age*.35)*.05
	var bob_amount := randf_range(1.0, 3.5)
	
	var cycle = fposmod(age * bob_speed + bob_offset, TAU)
	var t = abs(cycle / PI - 1.0)


	position.x += speed * drift * direction * delta

	position.y = start_y + (t - 0.5) * bob_height

	
	if direction == -1:
		modulate.a = clamp((640-position.x)/200.0,0,max_alpha)
	else:
		modulate.a = clamp((position.x+100)/200.0,0,max_alpha)

	
	if direction == -1 and position.x < -250:
		finished.emit(layer)
		queue_free()

	elif direction == 1 and position.x > 720:
		finished.emit(layer)
		queue_free()
