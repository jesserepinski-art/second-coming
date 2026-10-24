extends Area2D
class_name CutsceneTrigger

@export var director: CutsceneDirector

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if director == null or BattleManager.current_battle:
		return
	if not body.is_in_group("player"):
		return
	await director.play()
	if director.once_flag != "":
		queue_free()
