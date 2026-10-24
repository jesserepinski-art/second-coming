extends Enemy

@onready var rig: Node2D = $Lailah
@onready var clam: AnimatedSprite2D = $Lailah/Clam
@onready var pillow: Sprite2D = $Lailah/Clam/Pillow
@onready var woman_face: Sprite2D = $Lailah/Clam/WomanFace
@onready var woman_hair: Sprite2D = $Lailah/Clam/WomanFace/WomanHair
@onready var woman_body: Sprite2D = $Lailah/Clam/WomanBody
@onready var pearl: Sprite2D = $Lailah/Clam/Pearl
@onready var fetus: Sprite2D = $Lailah/Clam/Fetus
@onready var blood: AnimatedSprite2D = $Lailah/Clam/Blood
@onready var animationplayer: AnimationPlayer = $Lailah/AnimationPlayer
@export var phase_two_threshold: float = 0.4 
var phase_two_triggered := false

func _ready() -> void:
	animationplayer.play("idle")
	clam.play("opened")
	fetus.visible = false
	blood.visible = false

	if data:
		data.hp_changed.connect(_on_lailah_hp_changed)

func _on_lailah_hp_changed(hp: int, hp_max: int, _amount_change: int) -> void:
	if phase_two_triggered:
		return

	var hp_percent := float(hp) / float(hp_max)
	if hp_percent <= phase_two_threshold:
		phase_two_triggered = true
		_start_phase_two()

func _start_phase_two() -> void:
	clam.play("closed")
	pillow.visible = false
	woman_face.visible = false
	woman_hair.visible = false
	woman_body.visible = false
	pearl.visible = false
	


	blood.visible = true
	blood.play("closed")
	await blood.animation_finished

	blood.visible = false
	clam.play("opened")
	fetus.visible = true
	

	
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
	
