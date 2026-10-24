extends Node2D

@export var mote_scene: PackedScene

@export var far_count := 80
@export var mid_count := 50
@export var near_count := 25

@onready var far := $Far
@onready var mid := $Mid
@onready var near := $Near

const FAR := 0
const MID := 1
const NEAR := 2


func _ready():
	randomize()

	for i in range(far_count):
		spawn(FAR)

	for i in range(mid_count):
		spawn(MID)

	for i in range(near_count):
		spawn(NEAR)


func spawn(layer:int):

	if mote_scene == null:
		return

	var mote = mote_scene.instantiate()

	match layer:

		FAR:
			far.add_child(mote)

			mote.setup(
				layer,
				Vector2(
					randf_range(-150,1450),
					randf_range(720,900)
				)
			)

		MID:
			mid.add_child(mote)

			mote.setup(
				layer,
				Vector2(
					randf_range(-150,1450),
					randf_range(720,900)
				)
			)

		NEAR:
			near.add_child(mote)

			mote.setup(
				layer,
				Vector2(
					randf_range(-150,1450),
					randf_range(720,900)
				)
			)

	mote.finished.connect(_on_mote_finished)


func _on_mote_finished(layer:int):
	spawn(layer)
