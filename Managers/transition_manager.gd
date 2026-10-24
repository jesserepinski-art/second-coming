extends CanvasLayer
@onready var top := $TopLid
@onready var bottom := $BottomLid
@onready var fade_rect := $FadeRect
@onready var left_clouds := $LeftClouds
@onready var right_clouds := $RightClouds

const OPEN_TIME := 0.7
const CLOUD_TIME := 1.0
const CLOUD_WIDTH := 966.4


const LEFT_CLOSED_X := 320.0 - CLOUD_WIDTH    
const RIGHT_CLOSED_X := 320.0 - CLOUD_WIDTH


const LEFT_OPEN_X := -640 - CLOUD_WIDTH
const RIGHT_OPEN_X := 640.0

func close_clouds() -> void:
	left_clouds.show()
	right_clouds.show()
	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(left_clouds, "position:x", LEFT_CLOSED_X, CLOUD_TIME)
	tween.tween_property(right_clouds, "position:x", RIGHT_CLOSED_X, CLOUD_TIME)
	await tween.finished

func open_clouds() -> void:
	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(left_clouds, "position:x", LEFT_OPEN_X, OPEN_TIME)
	tween.tween_property(right_clouds, "position:x", RIGHT_OPEN_X, OPEN_TIME)
	await tween.finished
	left_clouds.hide()
	right_clouds.hide()

const TIME := 0.3
const CLOSED_TOP := 0.0
const CLOSED_BOTTOM := 180.0
const OPEN_TOP := -180.0
const OPEN_BOTTOM := 360.0

func close_eyes() -> void:
	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(top, "position:y", CLOSED_TOP, TIME)
	tween.tween_property(bottom, "position:y", CLOSED_BOTTOM, TIME)
	await tween.finished

func open_eyes() -> void:
	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(top, "position:y", OPEN_TOP, TIME)
	tween.tween_property(bottom, "position:y", OPEN_BOTTOM, TIME)
	await tween.finished

func fade_to_black(duration := 0.5) -> void:
	fade_rect.modulate.a = 0.0
	fade_rect.show()
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, duration)
	await tween.finished

func fade_from_black(duration := 0.5) -> void:
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, duration)
	await tween.finished
	fade_rect.hide()
