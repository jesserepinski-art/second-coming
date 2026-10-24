extends Node
class_name PartyFollowerManager

const FOLLOWER_SCENE: PackedScene = preload("res://Players/PartyFollower.tscn")

var followers: Array[Node2D] = []



func _ready() -> void:
	print("PartyFollowerManager ready")
	Data.party_changed.connect(_on_party_changed)
	_rebuild_followers()


func _rebuild_followers() -> void:
	for f in followers:
		f.queue_free()
	followers.clear()

	var previous: Node2D = get_tree().get_first_node_in_group("player")
	var ground_layers := _get_current_ground_layers()

	for i in range(1, Data.party.size()):
		var actor: BattleActor = Data.party[i]
		var follower := FOLLOWER_SCENE.instantiate()
		get_tree().root.get_node("Main").add_child.call_deferred(follower)
		follower.global_position = previous.global_position
		follower.follow_target = previous
		follower.set_ground_layers(ground_layers)  
		follower.setup_sprite(actor.overworld_sprite_frames) 
		followers.append(follower)
		previous = follower

func _get_current_ground_layers() -> Array[TileMapLayer]:
	var level_manager = get_tree().root.get_node("Main/LevelManager")
	var layers: Array[TileMapLayer] = []
	for child in level_manager.current_level.get_children():
		if child is TileMapLayer:
			layers.append(child)
	return layers
func _on_party_changed() -> void:
	print("party_changed signal received")
	_rebuild_followers()

func update_all_ground_layers(layers: Array[TileMapLayer]) -> void:
	for follower in followers:
		if follower.has_method("set_ground_layers"):
			follower.set_ground_layers(layers)
