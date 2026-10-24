class_name BossEnemy extends Enemy

@onready var rig: Node2D = $Phanuel
@onready var wings: AnimatedSprite2D = $Phanuel/Body/Wings


func _ready() -> void:
	if wings:
		wings.z_as_relative = true
		wings.show_behind_parent = true
		
	else:
		print("Wings reference is null — path is wrong")
		wings.z_as_relative = true
		wings.show_behind_parent = false
	if data:
		refresh_status_icons()
	

func play_attack_animation() -> void:
	if rig and rig.has_node("AnimationPlayer") and rig.get_node("AnimationPlayer").has_animation("attack"):
		var anim: AnimationPlayer = rig.get_node("AnimationPlayer")
		anim.play("attack")
		await anim.animation_finished
	else:
		await super.play_attack_animation()
func play_spell_animation() -> void:
	if rig and rig.has_node("AnimationPlayer"):
		var anim: AnimationPlayer = rig.get_node("AnimationPlayer")
		anim.play("cast_spell")
		await anim.animation_finished
	else:
		await super.play_spell_animation()
