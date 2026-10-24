class_name BattleEffects
extends Node

@onready var spell_animation: VideoStreamPlayer = $"../SpellAnimation"

@onready var attack_animation: VideoStreamPlayer = $"../AttackAnimation"
@onready var attack_sfx: AudioStreamPlayer = $AttackSFX
@onready var spell_sfx: AudioStreamPlayer = $SpellSFX
@onready var impact_sfx: AudioStreamPlayer = $ImpactSFX
@onready var main_attack: VideoStreamPlayer = $"../MainAttack"
@onready var spell_cast: VideoStreamPlayer = $"../SpellCast"
@onready var effect: VideoStreamPlayer = $"../Effect"
var current_attack: AttackData = null
var current_spell: Item = null
@onready var sequence_player: AnimationPlayer = $"../SequencePlayer"
@onready var flash_rect: ColorRect = $"../FlashRect"

func _ready() -> void:
	Globals.battle_effects = self


func play_player_attack(attack: AttackData) -> void:
	
	current_attack = attack

	main_attack.stream = attack.attack_video
	effect.stream = attack.effect_video
	main_attack.show()
	effect.show()
	sequence_player.play("player_attack")
	await sequence_player.animation_finished

	cleanup_attack_visuals()
	
func play_player_video():
	if main_attack.stream == null:
		return

	main_attack.stop()
	main_attack.play()
func play_spell(actor: BattleActor, spell: Item) -> void:
	current_spell = spell


	effect.stream = spell.effect_video

	var anim: StringName = actor.spell_cast_animation
	if anim == StringName():
		anim = &"cast_spell"

	sequence_player.play(anim)
	await sequence_player.animation_finished

	cleanup_attack_visuals()
func play_spell_sound() -> void:
	if current_spell == null or current_spell.cast_sound == null:
		return

	spell_sfx.stream = current_spell.cast_sound
	Util.audio_play_varied_pitch(spell_sfx)
func play_effect(video: VideoStream) -> void:
	if video == null:
		return

	effect.stream = video
	effect.show()
	effect.stop()
	effect.play()
func play_spell_animation() -> void:
	if current_spell == null:
		return

	if current_spell.attack_video == null:
		return

	spell_animation.stream = current_spell.attack_video
	spell_animation.stop()
	spell_animation.play()
	
func stop_effect() -> void:
	effect.stop()
	effect.stream = null
	effect.hide()





func flash() -> void:
	if flash_rect.has_method("flash"):
		flash_rect.flash()


func shake(amount: float = 0.5) -> void:
	if Globals.screen_shake:
		Globals.screen_shake.add_trauma(amount)
func play_enemy_attack(attack: AttackData) -> void:


	if attack == null:
		push_error("attack is null")
		return

	if attack_animation == null:
		push_error("attack_animation node is null")
		return

	if effect == null:
		push_error("effect node is null")
		return

	current_attack = attack

	attack_animation.stream = attack.attack_video

	if attack.effect_video:
		effect.stream = attack.effect_video

	sequence_player.play("enemy_spell")
	await sequence_player.animation_finished

	cleanup_attack_visuals()
func play_attack_sound() -> void:
	if current_attack == null or current_attack.cast_sound == null:
		return

	attack_sfx.stream = current_attack.cast_sound
	Util.audio_play_varied_pitch(attack_sfx)
func play_spell_impact_sound() -> void:
	if current_spell == null or current_spell.impact_sound == null:
		return

	impact_sfx.stream = current_spell.impact_sound
	Util.audio_play_varied_pitch(impact_sfx)
func play_hurt_sound(actor: BattleActor) -> void:
	if actor == null:
		return

	if actor.hurt_sound == null:
		return

	impact_sfx.stream = actor.hurt_sound
	Util.audio_play_varied_pitch(impact_sfx)
func cleanup_attack_visuals() -> void:
	main_attack.stop()
	main_attack.stream = null

	attack_animation.stop()
	attack_animation.stream = null

	spell_cast.stop()


	effect.stop()
	effect.stream = null
	
	spell_animation.stop()
	spell_animation.stream = null
	
	
	flash_rect.modulate.a = 0.0

	current_attack = null
func fade_out_attack_sound(duration: float = 0.25) -> void:
	if !attack_sfx.playing:
		return

	var tween := create_tween()
	tween.tween_property(attack_sfx, "volume_db", -80.0, duration)
	await tween.finished

	attack_sfx.stop()
	attack_sfx.volume_db = 0.0
func play_enemy_video():


	if attack_animation.stream == null:

		return



	attack_animation.show()
	attack_animation.stop()
	attack_animation.play()


func play_effect_video() -> void:
	if effect.stream == null:
		return

	effect.show()
	effect.stop()
	effect.play()
func begin_enemy_spell(spell: Item) -> void:

	current_spell = spell

	attack_animation.stream = spell.attack_video
	effect.stream = spell.effect_video

	sequence_player.play("enemy_spell")
	await sequence_player.animation_finished

	cleanup_attack_visuals()
