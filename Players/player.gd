extends CharacterBody2D
const RIPPLE_SCENE := preload("res://Ripple.tscn")
@export var speed := 250
@export var overworld_scale := 3.0
@export var overworld_speed := 500
@export var overworld_zoom := Vector2(0.1, 0.1)
@onready var reflection_sprite: AnimatedSprite2D = $PlayerReflection
@export var normal_scale := 1.0
@export var normal_speed := 350
@export var normal_zoom := Vector2(0.55, 0.55)
@export var footstep_sounds: Dictionary = {
	"grass": [preload("res://Audio/Footsteps/Dirt/Steps_dirt-001.ogg"), preload("res://Audio/Footsteps/Dirt/Steps_dirt-002.ogg")],
	"stone": [preload("res://Audio/Footsteps/Floor/Steps_floor-018.ogg"), preload("res://Audio/Footsteps/Floor/Steps_floor-019.ogg")],
	"water": [preload("res://Audio/Footsteps/Water/Steps_water-006.ogg"), preload("res://Audio/Footsteps/Water/Steps_water-012.ogg")],
	"mar'rah": [preload("res://Audio/Footsteps/Floor/Steps_floor-018.ogg"), preload("res://Audio/Footsteps/Floor/Steps_floor-019.ogg")]
}
@export var step_interval := 0.35

@onready var footstep_player: AudioStreamPlayer2D = $FootstepPlayer
@onready var camera: Camera2D = $Camera2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var ground_layers: Array[TileMapLayer] = [] 
var step_timer := 0.0
var current_interactable: Interactable = null
var can_interact := true
var controllable := true

func _ready():
	$InteractionArea.area_entered.connect(_on_area_entered)
	$InteractionArea.area_exited.connect(_on_area_exited)

func set_overworld_mode(is_overworld: bool) -> void:
	if camera == null:
		camera = $Camera2D

	if is_overworld:
		scale = Vector2.ONE * overworld_scale
		speed = overworld_speed
		camera.zoom = overworld_zoom
	else:
		scale = Vector2.ONE * normal_scale
		speed = normal_speed
		camera.zoom = normal_zoom
	print(scale)
func _physics_process(delta):
	if not controllable:
		velocity = Vector2.ZERO
		return
	if Globals.textbox and Globals.textbox.is_active():
		velocity = Vector2.ZERO
		move_and_slide()
		return
	var input := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	velocity = input * speed

	if input != Vector2.ZERO:
		if abs(input.x) > abs(input.y):
			if input.x > 0:
				sprite.play("WalkRight")
			else:
				sprite.play("WalkLeft")
		else:
			if input.y > 0:
				sprite.play("WalkForward")
			else:
				sprite.play("WalkBack")
	else:
		sprite.stop() 

	if Input.is_action_just_pressed("interact"):
		if current_interactable:
			current_interactable.interact()

	move_and_slide()
	if velocity.length() > 0.0:
		step_timer -= delta
		if step_timer <= 0.0:
			_play_footstep()
			step_timer = step_interval
	else:
		step_timer = 0.0
	reflection_sprite.visible = (_get_terrain_under_player() == "water")
	if reflection_sprite.visible:
		reflection_sprite.sprite_frames = sprite.sprite_frames
		reflection_sprite.animation = sprite.animation
		reflection_sprite.frame = sprite.frame
func _play_footstep() -> void:
	var terrain := _get_terrain_under_player()
	var sounds: Array = footstep_sounds.get(terrain, [])
	if not sounds.is_empty():
		footstep_player.stream = sounds.pick_random()
		Util.audio_play_varied_pitch_2d(footstep_player, 0.08)

	if terrain == "water":
		_spawn_ripple()
func _spawn_ripple() -> void:
	var ripple := RIPPLE_SCENE.instantiate()
	get_tree().current_scene.add_child(ripple)
	ripple.global_position = global_position
	ripple.scale = Vector2.ONE * 0.4
func _get_terrain_under_player() -> String:
	for i in range(ground_layers.size() - 1, -1, -1):
		var layer := ground_layers[i]
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
func _on_area_entered(area):
	if area is Interactable:
		current_interactable = area
func _on_area_exited(area):
	if area == current_interactable:
		current_interactable = null
func _unhandled_input(event):

	if !can_interact:
		return

	if Globals.textbox and Globals.textbox.is_active():
		return

	if event.is_action_pressed("interact"):
		if current_interactable:
			can_interact = false
			current_interactable.interact()
