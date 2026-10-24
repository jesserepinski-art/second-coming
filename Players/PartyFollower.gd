extends CharacterBody2D
class_name PartyFollower

@export var follow_target: Node2D
@export var follow_distance := 24.0
@export var move_speed := 350

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var follower_reflection: AnimatedSprite2D = $FollowerReflection
var pending_sprite_frames: SpriteFrames
var position_history: Array[Vector2] = []
const HISTORY_SPACING := 4.0
var ground_layers: Array[TileMapLayer] = []
func _ready() -> void:
	if pending_sprite_frames:
		sprite.sprite_frames = pending_sprite_frames
func _physics_process(delta: float) -> void:
	if follow_target == null:
		return
	_record_history()
	var target_pos := _get_trail_position()
	var distance := global_position.distance_to(target_pos)
	if distance > 2.0:
		var direction := global_position.direction_to(target_pos)
		velocity = direction * move_speed
		_update_animation(direction)
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		sprite.stop()
	_update_reflection()

func _record_history() -> void:
	if position_history.is_empty() or position_history.back().distance_to(follow_target.global_position) >= HISTORY_SPACING:
		position_history.append(follow_target.global_position)
	if position_history.size() > 200:
		position_history.pop_front()

func _get_trail_position() -> Vector2:
	var steps_behind := int(follow_distance / HISTORY_SPACING)
	var index: int = max(0, position_history.size() - 1 - steps_behind)
	if position_history.is_empty():
		return global_position
	return position_history[index]

func _update_animation(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			if sprite.animation != "WalkRight":
				sprite.play("WalkRight")
		else:
			if sprite.animation != "WalkLeft":
				sprite.play("WalkLeft")
	else:
		if direction.y > 0:
			if sprite.animation != "WalkForward":
				sprite.play("WalkForward")
		else:
			if sprite.animation != "WalkBack":
				sprite.play("WalkBack")

func _update_reflection() -> void:
	var terrain := _get_terrain_under_follower()
	follower_reflection.visible = (terrain == "water")
	if follower_reflection.visible:
		follower_reflection.sprite_frames = sprite.sprite_frames
		follower_reflection.animation = sprite.animation
		follower_reflection.frame = sprite.frame

func _get_terrain_under_follower() -> String:
	for i in range(ground_layers.size() - 1, -1, -1):
		var layer := ground_layers[i]
		if not is_instance_valid(layer):
			continue
		var tile_set := layer.tile_set
		if tile_set == null or tile_set.get_custom_data_layers_count() == 0:
			continue
		var cell: Vector2i = layer.local_to_map(layer.to_local(global_position))
		var tile_data: TileData = layer.get_cell_tile_data(cell)
		if tile_data:
			var terrain_value = tile_data.get_custom_data("terrain_type")
			if terrain_value is String and terrain_value != "":
				return terrain_value
	return "grass"

func set_ground_layers(layers: Array[TileMapLayer]) -> void:
	ground_layers = layers




func setup_sprite(frames: SpriteFrames) -> void:
	if is_node_ready():
		sprite.sprite_frames = frames
	else:
		pending_sprite_frames = frames
