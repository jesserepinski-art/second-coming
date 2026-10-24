

class_name Menu extends Control

signal button_focused(button: BaseButton, index: int)
signal button_pressed(button: BaseButton, index: int)
signal activated()
signal closed()

const MENU_CURSOR: PackedScene = preload("res://Utility/menu_cursor.tscn")

@export var auto_wrap: bool = true
@export var buttons_container: Control = null
@export var focus_on_ready: bool = false
@export var hide_on_start: bool = false
@export var hide_on_focus_exit: bool = false
@export var hide_on_close: bool = false
@export var is_dummy: bool = false
@export var focused_sound: AudioStream
@export var pressed_sound: AudioStream
@export var use_idle_animation := true


static var tree: Array[Menu] = []


var idle_tween: Tween
var index: int = 0
var exiting: bool = false
var highlight_all: bool = false
var buttons: Array[Node] = []
var stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
var menu_cursor: MenuCursor = MENU_CURSOR.instantiate()

func _ready() -> void:
	set_process_unhandled_input(false)
	if !is_dummy:
		assert(buttons_container != null, "buttons_container not set on menu " + name + ". ")
	
	tree_exiting.connect(_on_tree_exiting)
	activated.connect(_on_activated)
	
	if not closed.is_connected(_on_closed):
		closed.connect(_on_closed)
	
	if is_dummy:
		return
		
	
	var child: Control
	
	var button: BaseButton = null
	var children: Array = buttons_container.get_children()
	if buttons_container:
		children = buttons_container.get_children()
	else:
		children = get_children()
	for i in range(children.size()):
		child = children[i]
		
		if child is BaseButton:
			button = child
		else:
			button = child.find_child("", true, false) as BaseButton
		if button == null:
			continue
		button.mouse_entered.connect(button.grab_focus)
		
		if !button.focus_entered.is_connected(
			Callable(self, "_on_button_focused").bind(button, i)
		):
			button.focus_entered.connect(
			Callable(self, "_on_button_focused").bind(button, i)
			)

		if !button.focus_exited.is_connected(
			Callable(self, "_on_button_focus_exited").bind(button)
		):
			button.focus_exited.connect(
			Callable(self, "_on_button_focus_exited").bind(button)
			)

		if !button.pressed.is_connected(
			Callable(self, "_on_button_pressed").bind(button, i)
		):
			button.pressed.connect(
			Callable(self, "_on_button_pressed").bind(button, i)
			)

		if !button.tree_exiting.is_connected(
			Callable(self, "_on_button_tree_exiting").bind(button)
		):
			button.tree_exiting.connect(
			Callable(self, "_on_button_tree_exiting").bind(button)
			)
		buttons.append(button)
		
		
	if !buttons.is_empty():
		_set_focus_neighbors()
		
	button_enable_focus(false)
	
	button_focused.connect(menu_cursor._on_menu_button_focused)
	closed.connect(menu_cursor._on_menu_closed)
	add_child(menu_cursor)
	add_child(stream_player)
	
	if focus_on_ready:
		button_focus()
		
	visible = not hide_on_start
	if use_idle_animation:
		start_idle()

func start_idle() -> void:
	if idle_tween:
		idle_tween.kill()

	pivot_offset = size / 2.0

	idle_tween = create_tween()
	idle_tween.set_loops()

	
	idle_tween.parallel().tween_property(
		self,
		"position:y",
		position.y - 1.5,
		2.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	idle_tween.parallel().tween_property(
		self,
		"rotation_degrees",
		0.15,
		2.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	idle_tween.parallel().tween_property(
		self,
		"scale",
		Vector2(1.01, 1.01),
		2.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	
	idle_tween.parallel().tween_property(
		self,
		"position:y",
		position.y + 1.5,
		4.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	idle_tween.parallel().tween_property(
		self,
		"rotation_degrees",
		-0.15,
		4.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	idle_tween.parallel().tween_property(
		self,
		"scale",
		Vector2.ONE,
		4.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	
	idle_tween.parallel().tween_property(
		self,
		"position:y",
		position.y,
		2.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	idle_tween.parallel().tween_property(
		self,
		"rotation_degrees",
		0.0,
		2.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		button_enable_focus(false)
		
		if hide_on_close:
			hide()
		closed.emit()
		get_viewport().set_input_as_handled()

func _set_focus_neighbors() -> void:
	
	await(get_tree().process_frame) 
	
	var buttons: Array[Node] = get_buttons()
	
	if buttons.is_empty():
		return
	if buttons.size() == 1:
		var single_btn: BaseButton = buttons[0]
		var btn_path: NodePath = single_btn.get_path()
		single_btn.focus_neighbor_left = btn_path
		single_btn.focus_neighbor_right = btn_path
		single_btn.focus_neighbor_top = btn_path
		single_btn.focus_neighbor_bottom = btn_path
		single_btn.focus_previous = btn_path
		single_btn.focus_next = btn_path
		return
	var _class: String = buttons_container.get_class()
	
	match _class:
		"GridContainer":
			var top_row: Array = []
			var bottom_row: Array = []
			var cols: int = buttons_container.columns
			@warning_ignore("integer_division")
			var rows: int = roundi(buttons.size() / cols)
			var btm_range: Array = [rows * cols - cols, rows * cols - 1]

			for x in cols:
	
				top_row.append(buttons[x])
			for x in range(btm_range[0], btm_range[1] + 1):

				if x > buttons.size():

					bottom_row.append(buttons[x - cols])
					continue

				bottom_row.append(buttons[x])
			
		
			for x in cols:
				var top_button: BaseButton = top_row[x]
				var bottom_button: BaseButton = bottom_row[x]

				if top_button == null or bottom_button == null:
					continue


				if top_button == bottom_button:
					continue
				
				if auto_wrap:
					top_button.focus_neighbor_top = bottom_button.get_path()
					top_button.focus_previous = bottom_button.get_path()
					bottom_button.focus_neighbor_bottom = top_button.get_path()
					bottom_button.focus_next = top_button.get_path()
				else:
					
					top_button.focus_neighbor_top = top_button.get_path()
					top_button.focus_previous = top_button.get_path()
					bottom_button.focus_neighbor_bottom = bottom_button.get_path()
					bottom_button.focus_next = bottom_button.get_path()
			
			
			for i in range(0, buttons.size(), cols):
				if i + cols - 1 >= buttons.size():
					continue

				var left_button: BaseButton = buttons[i]
				var right_button: BaseButton = buttons[i + cols - 1]

				if left_button == null or right_button == null:
					continue
				left_button.focus_neighbor_left = right_button.get_path()
				right_button.focus_neighbor_right = left_button.get_path()
		"VBoxContainer", "HBoxContainer":
			var first_button: BaseButton = buttons.front()
			var last_button: BaseButton = buttons.back()
			var first_button_path: NodePath = first_button.get_path()
			var last_button_path: NodePath = last_button.get_path()
			var first_neighbor_key: String = "focus_neighbor_left"
			var last_neighbor_key: String = "focus_neighbor_right"
			var path: NodePath = ""
			
			if _class == "VBoxContainer":
				first_neighbor_key = "focus_neighbor_top"
				last_neighbor_key = "focus_neighbor_bottom"
				
				for button: Node in buttons:
					path = button.get_path()
					button.focus_neighbor_left = path
					button.focus_neighbor_right = path
			else:
				for button: Node in buttons:
					path = button.get_path()
					button.focus_neighbor_top = path
					button.focus_neighbor_bottom = path
			
			first_button.set(first_neighbor_key, last_button_path)
			first_button.focus_previous = last_button_path
			last_button.set(last_neighbor_key, first_button_path)
			last_button.focus_next = first_button_path

func _close_menus_in_front_of_self() -> void:
	var tree_pos: int = tree.rfind(self)
	if tree_pos <= 0:
		return
		
	for i in range(tree.size() - 1, tree_pos, -1):
		tree.back().close()

func set_highlight_all(on: bool) -> void:
	highlight_all = on
		
func get_buttons_count() -> int:
	if !buttons_container:
		return 0
	return buttons_container.get_child_count()

func get_buttons() -> Array:
	return buttons

func get_first_focusable_button(and_focus: bool) -> BaseButton:
	for button in get_buttons():
		if button.visible and !button.disabled:
			if and_focus:
				button.grab_focus()
			return button
	return null

func connect_to_buttons(target: Object, _name: String = name) -> void:
	_name = _name.to_lower()
	var callable := Callable(target, "_on_" + _name + "_button_focused")
	if not button_focused.is_connected(callable):
		button_focused.connect(callable)
	callable = Callable(target, "_on_" + _name + "_button_pressed")
	if not button_pressed.is_connected(callable):
		button_pressed.connect(callable)

func menu_is_focused() -> bool:
	if not is_inside_tree():
		return false
	var focus_owner: Control = get_viewport().gui_get_focus_owner()
	if focus_owner == null:
		return true
	for button in get_buttons():
		if button == focus_owner:
			return true
	return false

func in_menu_tree() -> bool:
	return tree.has(self)

func button_enable_focus(on: bool) -> void:
	var mode: FocusMode = FocusMode.FOCUS_ALL if on else FocusMode.FOCUS_NONE
	for button in get_buttons():
		button.set_focus_mode(mode)
	
	if hide_on_focus_exit:	
		visible = on
		
	set_process_unhandled_input(on)
	Globals.menu_has_focus = on
	

func button_focus(n: int = index) -> void:
	if not is_inside_tree():
		return
	if !menu_is_focused():
		activated.emit()
	await get_tree().process_frame
	if not is_inside_tree():
		return
	show()
	button_enable_focus(true)
	
	if get_buttons_count() > 0:
		n = clampi(n, 0, get_buttons_count()-1)
		var button: BaseButton = buttons[n]
		if buttons.is_empty():
			return
		if button.is_inside_tree():
			if button.visible:
				button.grab_focus()
			else:
				get_first_focusable_button(true)
	else:
		var focus_owner: Control = get_viewport().gui_get_focus_owner()
		if focus_owner:
			focus_owner.release_focus()

func disable_all(on: bool = true) -> void:
	
	for button: BaseButton in get_buttons():
		button.disabled = on

func release() -> void:
	button_enable_focus(false)


func close(hide_also: bool = false) -> bool:
	if in_menu_tree():
		var button: BaseButton = buttons[index]
		button.release_focus()
		closed.emit()
		if hide_also:
			hide()
		return true
	return false

func _on_button_focused(button: BaseButton, button_index: int) -> void:
	index = button_index
	emit_signal("button_focused", button, index)
	
	if focused_sound:
		stream_player.stream = focused_sound
		stream_player.play()
	
	if highlight_all:
		for node in get_buttons():
			node.highlight(true)
	
func _on_button_focus_exited(_button: BaseButton) -> void:
	await get_tree().process_frame
	if tree:
		var m : Menu = tree.back()
		if is_instance_valid(m) and m.is_inside_tree():
			m.button_focus()
	if exiting:
		return
		
	if not get_viewport().gui_get_focus_owner() in get_buttons():
		button_enable_focus(false)
		
		if highlight_all:
			for node in get_buttons():
				node.highlight(false)
		set_highlight_all(false)

func _on_button_pressed(button: BaseButton, button_index: int) -> void:
	if pressed_sound:
		stream_player.stream = pressed_sound
		stream_player.play()
		
	emit_signal("button_pressed", button, button_index)

func _on_button_tree_exiting(button: BaseButton) -> void:
	if get_viewport().gui_get_focus_owner() == button:
		button_focus(index - 1)

func _on_tree_exiting() -> void:
	exiting = true

func _on_activated() -> void:
	print(name, " activated")
	print(tree)
	
	if in_menu_tree():
		pass
		
	else:
		tree.append(self)

func _on_closed() -> void:

	_close_menus_in_front_of_self()
	tree.pop_back()
	
	if tree:
		tree.back().button_focus()
func rebuild_buttons() -> void:
	buttons.clear()

	for child in buttons_container.get_children():
		var button: BaseButton = null

		if child is BaseButton:
			button = child
		else:
			for grandchild in child.get_children():
				if grandchild is BaseButton:
					button = grandchild
					break

		if button == null:
			continue

		if !button.mouse_entered.is_connected(button.grab_focus):
			button.mouse_entered.connect(button.grab_focus)

		if !button.focus_entered.is_connected(_on_button_focused.bind(button, buttons.size())):
			button.focus_entered.connect(_on_button_focused.bind(button, buttons.size()))

		if !button.focus_exited.is_connected(_on_button_focus_exited.bind(button)):
			button.focus_exited.connect(_on_button_focus_exited.bind(button))

		if !button.pressed.is_connected(_on_button_pressed.bind(button, buttons.size())):
			button.pressed.connect(_on_button_pressed.bind(button, buttons.size()))

		buttons.append(button)

	_set_focus_neighbors()

static func slide_fade_in(node: Control, from_offset: Vector2 = Vector2(0, 30), duration: float = 0.25) -> void:
	node.modulate.a = 0.0
	var start_pos := node.position
	node.position = start_pos + from_offset
	node.show()
	
	var tween := node.create_tween()
	tween.set_parallel()
	tween.tween_property(node, "modulate:a", 1.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "position", start_pos, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tween.finished

static func slide_fade_out(node:Control, to_offset: Vector2 = Vector2(0,30), duration: float = 0.2) -> void:
	var start_pos := node.position
	var tween := node.create_tween()
	tween.set_parallel()
	tween.tween_property(node, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "position", start_pos + to_offset, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween.finished
	node.hide()
	node.position = start_pos
