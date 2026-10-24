extends Area2D

var encountered := false
@export var battle_actors: Array[BattleActor]
@export var battle_music: AudioStream
@export var custom_background: PackedScene = null
@export var walk_speed := 80.0
@export var chase_speed := 130.0
@export var patrol_path: Node2D
@export var patrol_wait_time := 1.0
@export var detection_range := 100.0
@export var lose_interest_range := 160.0
@export var enemy_level: int = 1
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite_material: ShaderMaterial = ($AnimatedSprite2D.material as ShaderMaterial).duplicate()
@export var battle_music_volume_db: float = -10.0
@export var battle_stab: AudioStream
@export var battle_stab_volume_db: float = -5.0
@onready var orb_material: ShaderMaterial = $Orb.material.duplicate()
var patrol_points: Array[Marker2D] = []
var patrol_index := 0
var waiting := false
var chasing := false
var player: Node2D = null
const MAX_LEVEL := 100.0
func _ready():
	sprite.material = sprite_material
	if sprite == null:
		return
	if sprite_material == null:
		return
	$Orb.material = orb_material
	if orb_material == null:
		return
	_apply_level_visuals()
	body_entered.connect(_on_body_entered)

	if patrol_path:
		for child in patrol_path.get_children():
			if child is Marker2D:
				patrol_points.append(child)

	player = get_tree().get_first_node_in_group("player")
func _apply_level_visuals() -> void:
	var t := clampf(float(enemy_level) / MAX_LEVEL, 0.0, 1.0)

	
	if orb_material:
		var low_color := Color(1.0, 1.0, 1.0, 1.0)
		var mid_color := Color(0.7, 0.3, 0.9, 1.0)
		var high_color := Color(1.0, 0.05, 0.55, 1.0)

		var result_color: Color
		if t < 0.5:
			result_color = low_color.lerp(mid_color, t / 0.5)
		else:
			result_color = mid_color.lerp(high_color, (t - 0.5) / 0.5)

		orb_material.set_shader_parameter("light_color", result_color)
		orb_material.set_shader_parameter("flicker_strength", 0.05 + t * 0.35)
		orb_material.set_shader_parameter("pulse_speed", 1.0 + t * 1.5)

	
	var sprite_material := sprite.material as ShaderMaterial
	if sprite_material:
		sprite_material.set_shader_parameter("glitch_intensity", t * 0.6)
		sprite_material.set_shader_parameter("rgb_shift_amount", t * 0.02)
		sprite_material.set_shader_parameter("slice_count", lerp(6.0, 20.0, t))

func _physics_process(delta):
	if encountered:
		if sprite:
			sprite.stop()
		return

	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			return

	var distance_to_player := global_position.distance_to(player.global_position)

	if chasing:
		if distance_to_player > lose_interest_range:
			chasing = false
	else:
		if distance_to_player < detection_range:
			chasing = true
			waiting = false  

	if chasing:
		_process_chase(delta)
	else:
		_process_patrol(delta)

func _process_chase(delta: float) -> void:
	var direction := global_position.direction_to(player.global_position)
	global_position += direction * chase_speed * delta
	_update_animation(direction)

func _process_patrol(delta: float) -> void:
	if waiting or patrol_points.is_empty():
		if sprite:
			sprite.stop()
		return

	var target = patrol_points[patrol_index].global_position
	var direction = global_position.direction_to(target)
	global_position += direction * walk_speed * delta
	_update_animation(direction)

	if global_position.distance_to(target) < 4:
		_arrive()

func _update_animation(direction: Vector2) -> void:
	if not sprite:
		return
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

func _arrive() -> void:
	waiting = true
	global_position = patrol_points[patrol_index].global_position
	await get_tree().create_timer(patrol_wait_time).timeout
	patrol_index += 1
	if patrol_index >= patrol_points.size():
		patrol_index = 0
	waiting = false

func _on_body_entered(body):
	if encountered:
		hide()
		return
	if body is CharacterBody2D:
		body.process_mode = Node.PROCESS_MODE_DISABLED
		body.velocity = Vector2.ZERO
	else:
		return
	encountered = true

	var scaled_actors: Array[BattleActor] = []
	for base_actor in battle_actors:
		var instance := base_actor.copy()
		instance.scale_to_level(enemy_level)
		scaled_actors.append(instance)

	Encounter.enemies = scaled_actors
	Encounter.enemy_node = self
	Encounter.return_scene = get_tree().current_scene.scene_file_path
	Encounter.battle_music = battle_music
	Encounter.battle_background = custom_background
	Encounter.battle_music = battle_music
	Encounter.battle_music_volume = battle_music_volume_db
	call_deferred("_start_battle")
func _start_battle():
	
	BattleManager.begin_battle(Encounter.enemies)
