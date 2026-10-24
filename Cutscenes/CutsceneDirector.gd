extends Node
class_name CutsceneDirector

signal finished
signal _batch_done

@export var dialogue: DialogueSequence
@export var once_flag := ""
@export var freeze_player := true

var player_actor: CutsceneActor
var running := false
var _controlled: Array[CutsceneActor] = []
var _pending := 0

func play() -> void:
	if running:
		return
	if once_flag != "":
		if StoryFlags.has_flag(once_flag):
			return
		StoryFlags.set_flag(once_flag)
	running = true

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player_actor = player.get_node_or_null("CutsceneActor")
	if freeze_player and player_actor:
		control(player_actor)

	await _run()

	for a in _controlled:
		a.release()
	_controlled.clear()
	running = false
	finished.emit()

func _run() -> void:
	pass   

func control(a: CutsceneActor) -> void:
	if not _controlled.has(a):
		a.take_control()
		_controlled.append(a)

func move(a: CutsceneActor, pos: Vector2, speed: float = -1.0) -> void:
	control(a)
	await a.move_to(pos, speed)

func face(a: CutsceneActor, dir: Vector2) -> void:
	control(a)
	a.face(dir)

func wait(t: float) -> void:
	await get_tree().create_timer(t).timeout

func say(i: int) -> void:
	var line: DialogueLine = dialogue.lines[i]
	var n := line.speaker.name if line.speaker else ""
	var p: Texture2D = line.speaker.portrait if line.speaker else null
	var s: AudioStream = line.speaker.talk_sound if line.speaker else null
	await Globals.textbox.start(n, [line.text], p, s)
	await Globals.textbox.finished


func say_with(i: int, calls: Array) -> void:
	await all([say.bind(i)] + calls)

func all(calls: Array) -> void:
	_pending = calls.size()
	for c: Callable in calls:
		_run_one(c)
	if _pending > 0:
		await _batch_done

func _run_one(c: Callable) -> void:
	await c.call()
	_pending -= 1
	if _pending == 0:
		_batch_done.emit()

func run_animation(ap: AnimationPlayer, anim_name: StringName) -> void:
	ap.play(anim_name)
	await ap.animation_finished
