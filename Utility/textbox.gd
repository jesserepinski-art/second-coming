class_name Textbox extends PanelContainer

signal reached_end_of_line()
signal finished()

@export var instant: bool = false
@export var show_window: bool = true
@export var handle_input: bool = true
@export var pause_tree: bool = false
@export var use_sound: bool = true
@export var default_typing_sound: AudioStream
var idle_tween: Tween
var lines: Array = []
var speaker_name: String = ""
var current_position: Vector2 = Vector2.ZERO
var current_portrait: Texture2D = null
var current_typing_sound: AudioStream
@onready var speaker_label: Label = $MarginContainer/ScrollContainer/VBoxContainer/Speaker
@onready var dialogue: Label = $MarginContainer/ScrollContainer/VBoxContainer/Dialogue
@onready var portrait_rect: TextureRect = $MarginContainer/PortraitRect  
@onready var scroll_container: ScrollContainer = $MarginContainer/ScrollContainer
@onready var typewriter: Timer = $Typewriter
@onready var typing: AudioStreamPlayer = $Typing

func _enter_tree() -> void:
	Globals.textbox = self

func _ready() -> void:


	stop()
	self_modulate.a = 1.0 if show_window else 0.0
	start_idle()

func _unhandled_input(event: InputEvent) -> void:
	if !is_active():
		return

	if event.is_action_pressed("interact"):

		
		if !typewriter.is_stopped():
			typewriter.stop()
			dialogue.visible_characters = -1
			reached_end_of_line.emit()

		
		else:
			advance()

	elif event.is_action_pressed("ui_cancel"):
		stop()
	else:
		return

	get_viewport().set_input_as_handled()
	while Input.is_action_pressed("interact"):
		await get_tree().process_frame
func start_idle() -> void:
	if idle_tween:
		idle_tween.kill()

	pivot_offset = Vector2(size.x / 2.0, 0.0) 

	idle_tween = create_tween()
	idle_tween.set_loops()

	
	idle_tween.parallel().tween_property(
		self,
		"rotation_degrees",
		0.35,
		2.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	idle_tween.parallel().tween_property(
		self,
		"scale",
		Vector2(1.01, 1.01),
		2.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	
	idle_tween.parallel().tween_property(
		self,
		"rotation_degrees",
		-0.35,
		4.4
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	idle_tween.parallel().tween_property(
		self,
		"scale",
		Vector2.ONE,
		4.4
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	
	idle_tween.parallel().tween_property(
		self,
		"rotation_degrees",
		0.0,
		2.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	idle_tween.parallel().tween_property(
		self,
		"scale",
		Vector2.ONE,
		2.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func is_active() -> bool:
	return visible && !dialogue.text.is_empty()

func show_message(text: String) -> void:
	start("", [text])
	await finished
	
func observe(text: String, duration := 2.5) -> void:

	dialogue.text = text

	show()

	dialogue.visible_characters = 0

	typewriter.start()

	await reached_end_of_line

	await wait(duration)

	stop()

func start(speaker: String, text: Array, portrait: Texture2D = null, typing_sound: AudioStream = null) -> void:
	print("Textbox start called:", text)
	if lines:
		return

	

	if !text:
		stop()
		return

	speaker_name = speaker
	current_portrait = portrait
	current_typing_sound = typing_sound if typing_sound else default_typing_sound

	speaker_label.text = speaker_name
	speaker_label.visible = speaker_name != ""

	portrait_rect.texture = portrait
	portrait_rect.visible = portrait != null

	

	if pause_tree:
		get_tree().paused = true

	lines = text.duplicate()
	set_process_unhandled_input(handle_input)
	show()
	print("Textbox visible:", visible)
	print("Textbox modulate:", self_modulate)
	advance()
	while Input.is_action_pressed("interact"):
		await get_tree().process_frame
	
func stop() -> void:
	hide()
	lines.clear()
	dialogue.text = ""
	dialogue.visible_characters = -1
	typewriter.stop()
	set_process_unhandled_input(false)
	speaker_label.hide()
	speaker_label.text = ""
	portrait_rect.hide()
	portrait_rect.texture = null
	current_portrait = null
	if pause_tree:
		await(get_tree().process_frame)
		await(get_tree().process_frame)
		get_tree().paused = false

	finished.emit()
	
func add(text: String) -> void:
	dialogue.text += "\n" + text
	if !instant:
		typewriter.start()
	await(get_tree().process_frame)
	scroll_container.set_deferred("scroll_vertical", 99999)

func advance() -> void:
	print("Advance called. Remaining lines:", lines.size())

	if lines.is_empty():
		print("NO LINES LEFT -> STOP()")
		stop()
		return

	dialogue.text = lines.pop_front()
	print("Displaying:", dialogue.text)

	if instant:
		dialogue.visible_characters = -1
	else:
		dialogue.visible_characters = 0
		typewriter.start()

func wait(time: float) -> void:
	await(get_tree().create_timer(time).timeout)

func _on_typewriter_timeout() -> void:
	dialogue.visible_characters += 1
	if use_sound:
		typing.stream = current_typing_sound
		typing.play()

	if is_equal_approx(dialogue.visible_ratio, 1.0):
		dialogue.visible_characters = -1
		typewriter.stop()
		reached_end_of_line.emit()

func _on_player_moved(_pos: Vector2) -> void:
	stop()

func replace(text: String) -> void:
	start("", [text], current_portrait, current_typing_sound)
