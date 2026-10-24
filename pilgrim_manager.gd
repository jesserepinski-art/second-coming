extends Node2D

@export var pilgrim_scene: PackedScene

@export var far_count := 10
@export var mid_count := 7
@export var near_count := 4

@onready var far := $Far
@onready var mid := $Mid
@onready var near := $Near

const FAR := 0
const MID := 1
const NEAR := 2

func _ready():
	randomize()

	for i in range(far_count):
		spawn(FAR, true)

	for i in range(mid_count):
		spawn(MID, true)

	for i in range(near_count):
		spawn(NEAR, true)


func spawn(layer:int, initial:=false):

	if pilgrim_scene == null:
		return

	var pilgrim = pilgrim_scene.instantiate()

	
	var direction := -1

	if randf() < 0.2:
		direction = 1

	var x:float

	if initial:
		x = randf_range(-600,1900)
	else:
		if direction == -1:
			x = randf_range(1300,1500)
		else:
			x = randf_range(-250,-100)

	var y:float

	match layer:

		FAR:
			y = randf_range(100,190)
			far.add_child(pilgrim)

		MID:
			y = randf_range(170,270)
			mid.add_child(pilgrim)

		NEAR:
			y = randf_range(240,360)
			near.add_child(pilgrim)

	pilgrim.setup(layer, direction, Vector2(x,y))
	pilgrim.finished.connect(_on_pilgrim_finished)


func _on_pilgrim_finished(layer:int):
	spawn(layer,false)
