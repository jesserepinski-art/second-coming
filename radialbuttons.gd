extends Control

@export var radius := 260.0
@export var step_degrees := 10
@export var stiffness := 120.0   
@export var damping := 16.0      
@export var fade_per_step := 0.5
@export var min_scale := 0.8
@export var wrap := true        
@export var fade_steps := 1.8
var buttons: Array[Button] = []
var target := 0.0   
var _pos := 0.0    
var _vel := 0.0

func _ready() -> void:
	for c in get_children():
		if c is Button:
			buttons.append(c)
	var n := buttons.size()
	for i in n:
		var b := buttons[i]
		b.focus_entered.connect(_on_button_focused.bind(i))
		b.focus_neighbor_top = buttons[posmod(i - 1, n)].get_path()
		b.focus_neighbor_bottom = buttons[posmod(i + 1, n)].get_path()
		b.focus_neighbor_left = b.get_path()
		b.focus_neighbor_right = b.get_path()
	await get_tree().process_frame

func selected() -> int:
	return posmod(roundi(target), buttons.size())

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		_spin(1)
	elif event.is_action_pressed("ui_up"):
		_spin(-1)
	elif event.is_action_pressed("ui_accept"):
		buttons[selected()].pressed.emit()
	elif event is InputEventMouseButton and event.pressed:
		if event is InputEventMouseButton and event.pressed:
			var dir := 0
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				dir = 1
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
				dir = -1
			if dir != 0:
				buttons[posmod(selected() + dir, buttons.size())].grab_focus()

func _spin(dir: int) -> void:
	target += dir
	if not wrap:
		target = clampf(target, 0.0, buttons.size() - 1.0)

func _process(delta: float) -> void:
	if buttons.is_empty():
		return
	var accel := (target - _pos) * stiffness - _vel * damping
	_vel += accel * delta
	_pos += _vel * delta
	_layout()

func _layout() -> void:
	var n := buttons.size()
	
	var limit : float = minf(fade_steps, n / 2.0 - 0.05) if wrap else fade_steps
	for i in n:
		var b := buttons[i]
		var offset := i - _pos
		if wrap:
			offset = wrapf(offset, -n / 2.0, n / 2.0)
		var dist := absf(offset)
		var a := deg_to_rad(offset * step_degrees)
		var t := clampf(dist / limit, 0.0, 1.0)
		var alpha := 1.0 - smoothstep(0.0, 1.0, t)

		b.visible = alpha > 0.01
		b.pivot_offset = b.size / 2.0
		var p := Vector2(radius - cos(a) * radius, sin(a) * radius)
		b.position = p - b.size / 2.0
		b.rotation = -a
		b.scale = Vector2.ONE * lerpf(1.0, min_scale, t)
		b.modulate.a = alpha
		b.z_index = -int(dist * 10.0)
func _on_button_focused(i: int) -> void:
	var n := buttons.size()
	if wrap:
		var diff := posmod(i - selected(), n)
		if diff > n / 2:
			diff -= n
		target += diff
	else:
		target = float(i)
