class_name AttackData
extends Resource

@export var attack_name: String = "Attack"
@export var attack_video: VideoStream = null
@export var effect_video: VideoStream = null
@export var cast_sound: AudioStream
@export var impact_sound: AudioStream
@export var can_crit: bool = true
@export_range(-100, 100)
var crit_bonus: int = 0
@export var status_effect: StatusEffect = null

@export_range(0, 100)
var status_chance := 0
