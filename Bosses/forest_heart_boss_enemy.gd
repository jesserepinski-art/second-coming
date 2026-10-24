extends Enemy

@onready var rig: Node2D = $ForestBrain


func _ready() -> void:
	return
func play_attack_animation() -> void:
	
	if rig and rig.has_node("AnimationPlayer") and rig.get_node("AnimationPlayer").has_animation("attack"):
		var anim: AnimationPlayer = rig.get_node("AnimationPlayer")
		anim.play("attack")
		await anim.animation_finished
		anim.play("idle")
	else:
		await super.play_attack_animation()
	
func play_spell_animation() -> void:
	
	if rig and rig.has_node("AnimationPlayer"):
		var anim: AnimationPlayer = rig.get_node("AnimationPlayer")
		anim.play("cast_spell")
		await anim.animation_finished
		anim.play("idle")
	else:
		await super.play_spell_animation()
	
