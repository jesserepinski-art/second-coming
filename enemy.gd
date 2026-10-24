class_name Enemy extends TextureButton
const STATUS_ICON = preload("res://status_icon.tscn")
var base_scale := Vector2.ONE
@export var surreal_attack_scene: PackedScene = null
@onready var status_icons: HBoxContainer = $StatusIcons
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hit_flash: Timer = $HitFlash

@export var data: BattleActor = null :
	set(value):
		if data:
			if data.hp_changed.is_connected(_on_data_hp_changed):
				data.hp_changed.disconnect(_on_data_hp_changed)
			if data.statuses_changed.is_connected(_on_statuses_changed):
				data.statuses_changed.disconnect(_on_statuses_changed)

		if value:
			data = value.copy()
			data.hp_changed.connect(_on_data_hp_changed)
			data.statuses_changed.connect(_on_statuses_changed)

			if is_node_ready():
				_setup_sprite()
		else:
			data = null

var current_queued_attack: AttackData = null
var current_queued_spell: Item = null
var idle_detail_timer: Timer

func _ready() -> void:
	base_scale = scale
	animation_player.play("RESET")
	if data:
		_setup_sprite()
		refresh_status_icons()
	start_idle()

func _setup_sprite() -> void:
	if data.battle_sprite_frames:
		sprite.sprite_frames = data.battle_sprite_frames
		sprite.play("idle")
	_apply_level_distortion()

	if not data.idle_detail_animations.is_empty():
		if idle_detail_timer == null:
			idle_detail_timer = Timer.new()
			idle_detail_timer.timeout.connect(_play_idle_detail)
			add_child(idle_detail_timer)
		idle_detail_timer.wait_time = randf_range(3.0, 7.0)
		idle_detail_timer.start()

func _play_idle_detail() -> void:
	var detail: String = data.idle_detail_animations.pick_random()
	if sprite.sprite_frames.has_animation(detail):
		sprite.play(detail)
		await sprite.animation_finished
	if sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")
	if idle_detail_timer:
		idle_detail_timer.wait_time = randf_range(3.0, 7.0)
		idle_detail_timer.start()

var idle_tween: Tween

func start_idle() -> void:
	if idle_tween:
		idle_tween.kill()
	pivot_offset = size / 2.0
	var multiplier := randf_range(1.01, 1.03)
	var scale_amount := base_scale * multiplier
	var rotate_amount := randf_range(0.5, 1.0)
	var speed := randf_range(1.5, 2.5)

	idle_tween = create_tween()
	idle_tween.set_loops()
	idle_tween.parallel().tween_property(self, "scale", scale_amount, speed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	idle_tween.parallel().tween_property(self, "rotation_degrees", rotate_amount, speed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	idle_tween.parallel().tween_property(self, "scale", base_scale, speed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	idle_tween.parallel().tween_property(self, "rotation_degrees", -rotate_amount, speed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	idle_tween.tween_property(self, "rotation_degrees", 0.0, speed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _process(_delta: float) -> void:
	if not hit_flash.is_stopped():
		modulate.a = randf()

func play_attack_animation() -> void:
	var was_focused := has_focus()
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("attack"):
		sprite.play("attack")
		await sprite.animation_finished
	sprite.play("idle")
	Globals.screen_shake.add_trauma()
	if was_focused:
		animation_player.play("highlight")
	else:
		animation_player.play("RESET")

func play_spell_animation() -> void:
	var was_focused := has_focus()
	if Globals.battle_effects:
		await Globals.battle_effects.begin_enemy_spell(current_queued_spell)
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("cast_spell"):
		sprite.play("cast_spell")
		await sprite.animation_finished
	sprite.play("idle")
	Globals.screen_shake.add_trauma()
	if was_focused:
		animation_player.play("highlight")
	else:
		animation_player.play("RESET")

func _on_focus_entered() -> void:
	animation_player.play("highlight")

func _on_focus_exited() -> void:
	animation_player.play("RESET")

func _on_data_hp_changed(hp: int, _hp_max: int, value_change: int) -> void:
	if value_change < 0:
		if Globals.battle_effects:
			Globals.battle_effects.play_hurt_sound(data)
		hit_flash.start()
		await hit_flash.timeout
	if hp <= 0:
		if has_focus():
			release_focus()
		var tween: Tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_QUART)
		await tween.finished
		hide()

func _on_hit_flash_timeout() -> void:
	modulate.a = 1.0

func refresh_status_icons() -> void:
	for child in status_icons.get_children():
		child.queue_free()
	if data == null:
		return
	for status: StatusEffect in data.statuses:
		var icon = STATUS_ICON.instantiate()
		icon.texture = status.icon
		status_icons.add_child(icon)

func _on_statuses_changed() -> void:
	refresh_status_icons()
func _apply_level_distortion() -> void:
	var material := sprite.material as ShaderMaterial
	if material == null:
		return

	var t := clampf(float(data.level) / 100.0, 0.0, 1.0)

	material.set_shader_parameter("glitch_intensity", t * 0.7)
	material.set_shader_parameter("rgb_shift_amount", t * 0.025)
	material.set_shader_parameter("slice_count", lerp(4.0, 24.0, t))
