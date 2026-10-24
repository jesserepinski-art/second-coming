extends Node
class_name CutsceneActor

@export var walk_speed := 80.0
@export var sprite_path: NodePath = ^"../AnimatedSprite2D"
@export var anim_right: StringName = &"WalkRight"
@export var anim_left: StringName = &"WalkLeft"
@export var anim_down: StringName = &"WalkForward"
@export var anim_up: StringName = &"WalkBack"

var body: Node2D
var sprite: AnimatedSprite2D
var facing := Vector2.DOWN
var _was_physics := true

func _ready() -> void:
	body = get_parent() as Node2D
	sprite = get_node_or_null(sprite_path) as AnimatedSprite2D

func take_control() -> void:
	if "controllable" in body:
		body.controllable = false
	else:
		_was_physics = body.is_physics_processing()
		body.set_physics_process(false)   

func release() -> void:
	if "controllable" in body:
		body.controllable = true
	else:
		body.set_physics_process(_was_physics)

func move_to(target: Vector2, speed: float = -1.0) -> void:
	if speed <= 0.0:
		speed = walk_speed
	while body.global_position.distance_to(target) > 0.5:
		_play_walk(body.global_position.direction_to(target))
		body.global_position = body.global_position.move_toward(target, speed * get_process_delta_time())
		await get_tree().process_frame
	body.global_position = target
	face(facing)

func face(dir: Vector2) -> void:
	facing = dir
	if sprite == null:
		return
	sprite.play(_anim_for(dir))
	sprite.stop()
	sprite.frame = 0

func play_anim(anim_name: StringName, wait := true) -> void:
	if sprite == null:
		return
	sprite.play(anim_name)
	if wait:
		await sprite.animation_finished

func _play_walk(dir: Vector2) -> void:
	facing = dir
	if sprite == null:
		return
	var anim := _anim_for(dir)
	if sprite.animation != anim or not sprite.is_playing():
		sprite.play(anim)

func _anim_for(dir: Vector2) -> StringName:
	if abs(dir.x) > abs(dir.y):
		return anim_right if dir.x > 0 else anim_left
	return anim_down if dir.y > 0 else anim_up
