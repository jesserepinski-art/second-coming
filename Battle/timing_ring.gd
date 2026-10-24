extends Control
class_name TimingRing

signal completed(tier: String)
const TIER_MULTIPLIERS := {
	"perfect": 1.5,
	"good": 1.1,
	"poor": 0.8,
	"miss": 0.4,
}
@onready var timing_ring: TimingRing = $TimingRing
@export var window_time := 1.0
@export var start_radius := 120.0
@export var target_radius := 40.0
@export var ring_thickness := 6.0


@export var perfect_threshold := 6.0
@export var good_threshold := 16.0
@export var poor_threshold := 32.0
@export var input_guard_time := 0.15 
var guard_timer := 0.0
var anchor_alpha := 1.0
var anchor_tween: Tween
var spin := 0.0
var trail: Array[float] = []
var flash := 0.0
var flash_color := Color.WHITE
var flash_tween: Tween
var current_radius: float
var elapsed := 0.0
var active := false
var result_locked := false

func _enter_tree() -> void:
	Globals.timing_ring = self
func _ready() -> void:
	current_radius = start_radius
	set_process(false)

func start() -> void:
	if flash_tween:
		flash_tween.kill()
	flash = 0.0
	if anchor_tween:
		anchor_tween.kill()
	anchor_alpha = 1.0
	current_radius = start_radius
	elapsed = 0.0
	guard_timer = input_guard_time 
	active = true
	result_locked = false
	set_process(true)
	show()
	queue_redraw()
	
func _process(delta: float) -> void:
	spin += delta * 1.2
	if not active:
		return

	
	if guard_timer > 0.0:
		guard_timer -= delta

	elapsed += delta
	var t: float = clampf(elapsed / window_time, 0.0, 1.0)
	current_radius = lerp(start_radius, 0.0, t)
	queue_redraw()


	if Input.is_action_just_pressed("interact") and not result_locked:
		if guard_timer <= 0.0:
			_resolve()
	elif t >= 1.0 and not result_locked:
		_resolve(true)  
	trail.push_front(current_radius)
	if trail.size() > 6:
		trail.pop_back()
func _resolve(timed_out: bool = false) -> void:
	result_locked = true
	active = false
	set_process(false)

	var distance: float = abs(current_radius - target_radius)
	var tier: String

	if timed_out:
		tier = "miss"
	elif distance <= perfect_threshold:
		tier = "perfect"
	elif distance <= good_threshold:
		tier = "good"
	elif distance <= poor_threshold:
		tier = "poor"
	else:
		tier = "miss"
	
	queue_redraw()
	completed.emit(tier)
	_play_result(tier)
func _draw() -> void:
	if not active and flash <= 0.0:
		return
	var center := size / 2.0
	var fade := anchor_alpha
	
	
	draw_circle(center, target_radius + poor_threshold, Color(1, 1, 1, 0.03 * fade))
	draw_arc(center, target_radius, 0, TAU, 64, Color(1, 0.85, 0.4, 0.15 * fade), perfect_threshold * 2)

	var pulse := 1.0 + sin(Time.get_ticks_msec() * 0.004) * 0.03
	var anchor := Color(1, 1, 1, fade)
	draw_arc(center, target_radius, 0, TAU, 64, anchor, ring_thickness)
	var cross_len := 4.0
	var offset := target_radius
	draw_line(center + Vector2(offset, 0), center + Vector2(offset + cross_len, 0), anchor, 2.0)
	draw_line(center - Vector2(offset, 0), center - Vector2(offset + cross_len, 0), anchor, 2.0)
	draw_line(center + Vector2(0, offset), center + Vector2(0, offset + cross_len), anchor, 2.0)
	draw_line(center - Vector2(0, offset), center - Vector2(0, offset + cross_len), anchor, 2.0)
	
	if active:
		var distance: float = abs(current_radius - target_radius)
		var closeness := 1.0 - clampf(distance / (poor_threshold * 2.0), 0.0, 1.0)
		var ring_color := Color.WHITE  

	
		for i in trail.size():
			var a := 0.25 * (1.0 - float(i) / trail.size())
			draw_arc(center, trail[i], 0, TAU, 48, Color(ring_color, a), ring_thickness - 2.0)

	
		_draw_segmented(center, current_radius, ring_color, ring_thickness - 1.0, 16, 0.3, spin * (1.0 + closeness * 3.0))

	
		for i in 8:
			var ang := -spin * 0.5 + i * TAU / 8.0
			var dir := Vector2.from_angle(ang)
			draw_line(center + dir * current_radius, center + dir * (current_radius - 6.0), ring_color, 2.0)

	
		draw_arc(center, target_radius, 0, TAU, 64, Color(ring_color, closeness * 0.3), ring_thickness + closeness * 10.0)
		
		if current_radius > target_radius:
			draw_arc(center, current_radius + 4.0, 0, TAU, 48, Color(ring_color.r, ring_color.g, ring_color.b, 0.2), 1.0)
func _draw_segmented(c: Vector2, r: float, col: Color, w: float, segs := 12, gap := 0.4, rot := 0.0) -> void:
	var step := TAU / segs
	for i in segs:
		var a := rot + i * step
		draw_arc(c, r, a, a + step * (1.0 - gap), 8, col, w)
func _play_result(tier: String) -> void:
	flash_color = {
		"perfect": Color.GOLD,
		"good": Color.AQUAMARINE,
		"poor": Color.ORANGE,
		"miss": Color(1, 0.3, 0.3),
	}[tier]
	flash = 1.0
	if anchor_tween:
		anchor_tween.kill()
	anchor_tween = create_tween()
	anchor_tween.tween_property(self, "anchor_alpha", 0.0, 0.12)
	if flash_tween:
		flash_tween.kill()
	flash_tween = create_tween()
	flash_tween.tween_method(_set_flash, 1.0, 0.0, 0.5 if tier == "perfect" else 0.3)
	flash_tween.tween_callback(hide)

func _set_flash(v: float) -> void:
	flash = v
	queue_redraw()
