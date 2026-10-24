extends Node

@onready var attack_animation: VideoStreamPlayer = $"."



func pause_video() -> void:
	attack_animation.paused = true


func resume_video() -> void:
	attack_animation.paused = false


func toggle_video() -> void:
	attack_animation.paused = !attack_animation.paused
