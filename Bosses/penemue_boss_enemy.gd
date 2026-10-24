extends Enemy

@onready var rig: Node2D = $PenemueRig
@onready var hand: AnimatedSprite2D = $PenemueRig/Hand

func _ready() -> void:
	hand.play("idle")
func play_attack_animation() -> void:
	hand.play("attack")
	if rig and rig.has_node("AnimationPlayer") and rig.get_node("AnimationPlayer").has_animation("attack"):
		var anim: AnimationPlayer = rig.get_node("AnimationPlayer")
		anim.play("attack")
		await anim.animation_finished
		anim.play("idle")
	else:
		await super.play_attack_animation()
	hand.play("idle")
func play_spell_animation() -> void:
	hand.play("attack")
	if rig and rig.has_node("AnimationPlayer"):
		var anim: AnimationPlayer = rig.get_node("AnimationPlayer")
		anim.play("cast_spell")
		await anim.animation_finished
		anim.play("idle")
	else:
		await super.play_spell_animation()
	hand.play("idle")
