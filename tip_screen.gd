extends Control
class_name TipScreen

signal closed

@onready var title_label: Label = $Panel/TitleLabel
@onready var video: VideoStreamPlayer = $Panel/MediaVideo
@onready var image: TextureRect = $Panel/MediaImage
@onready var body_label: Label = $Panel/BodyLabel

var _page_done := false

func _enter_tree() -> void:
	Globals.tip_screen = self

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

func show_once(tip: TipData) -> void:
	if tip == null or StoryFlags.has_flag("tip_seen_" + tip.tip_id):
		return
	StoryFlags.set_flag("tip_seen_" + tip.tip_id)
	await show_tip(tip)

func show_tip(tip: TipData) -> void:
	var was_paused := get_tree().paused
	get_tree().paused = true
	await Menu.slide_fade_in(self)
	show()
	

	for page: TipPage in tip.pages:
		title_label.text = page.title
		body_label.text = page.text

		image.visible = page.image != null
		image.texture = page.image
		video.visible = page.video != null
		if page.video:
			video.stream = page.video
			video.play()
			if not video.finished.is_connected(video.play):
				video.finished.connect(video.play)  
		else:
			video.stop()

		_page_done = false
		while not _page_done:
			await get_tree().process_frame

	video.stop()
	await Menu.slide_fade_out(self)
	hide()
	get_tree().paused = was_paused
	closed.emit()

func _input(event: InputEvent) -> void:
	if visible and (event.is_action_pressed("interact") or event.is_action_pressed("ui_accept")):
		_page_done = true
		get_viewport().set_input_as_handled()
