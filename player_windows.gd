class_name PlayerWindows extends Menu

var active_index: int = -1
var tween: Tween = null
@onready var party: Array = Data.party
@export var lowered_amount := 55
var rest_y: float
var rest_position: Vector2
var lowered_position: Vector2


func _ready() -> void:
	rest_y = position.y
	print("rest_y:", rest_y)
	for i in range(get_child_count()):
		if get_child(i) is Control:
			get_child(i).focus_mode = Control.FOCUS_NONE
		if i < party.size():
			get_child(i).data = party[i]
		else:
			get_child(i).data = null
	super()
func activate(player_index: int) -> void:
	if active_index == player_index:
		return
		
	if active_index != -1:
		get_child(active_index).activate(false)
		
	active_index = player_index
	
	if active_index != -1:
		get_child(active_index).activate(true)
func lower() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.finished.connect(func():
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	)

func raise() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.6)
