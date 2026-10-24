extends CharacterBody2D
class_name ProvidenceCutsceneActor

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	sprite.play("IdleBack")  
