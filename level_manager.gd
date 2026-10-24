extends Node

@export var starting_level: PackedScene
var current_level_music: AudioStream
var current_level_music_volume: float = 0.0
var current_level: Node = null

func _ready():
	var s := SaveManager.pending_load
	if s:
		SaveManager.apply_pending()
		load_level(load(s.level_path))
		get_tree().get_first_node_in_group("player").global_position = s.player_position
		Data.party_changed.emit() 
		await TransitionManager.fade_from_black(0.8)
	else:
		load_level(starting_level)

func load_level(level_scene: PackedScene, spawn_name := "Entrance"):
	print("Loading:", level_scene)
	if level_scene == null:
		push_error("LEVEL SCENE IS NULL")
		return
	if current_level:
		current_level.queue_free()
	current_level = level_scene.instantiate()
	add_child(current_level)
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_error("No player found in 'player' group")
		return

	player.set_overworld_mode(current_level.is_in_group("overworld"))
	_apply_camera_bounds(player)
	BanterManager.active = current_level.is_in_group("overworld")

	var layers: Array[TileMapLayer] = []
	for child in current_level.get_children():
		if child is TileMapLayer:
			layers.append(child)

	if player.has_method("set_ground_layers"):
		player.set_ground_layers(layers)

	var follower_manager = get_tree().root.get_node_or_null("Main/PartyFollowerManager")
	if follower_manager:
		follower_manager.update_all_ground_layers(layers)

	var target_marker: Node = null
	for marker in get_tree().get_nodes_in_group("spawn"):
		if current_level.is_ancestor_of(marker) and marker.spawn_name == spawn_name:
			target_marker = marker
			break
	if target_marker:
		player.global_position = target_marker.global_position
	else:
		push_warning("No spawn marker named '%s' found in level" % spawn_name)
	if current_level.has_method("get") and "ambient_sound" in current_level:
		AmbientManager.play(current_level.ambient_sound, current_level.ambient_volume_db)
	else:
		AmbientManager.stop()
	if current_level.has_method("get") and "zone_level" in current_level:
		var avg_party_level := 0.0
		for actor in Data.party:
			avg_party_level += actor.level
		avg_party_level /= max(Data.party.size(), 1)

		var gap := clampf((current_level.zone_level - avg_party_level) / 20.0, 0.0, 1.0)
		Globals.danger_overlay.set_danger(gap)
	else:
		Globals.danger_overlay.set_danger(0.0)
func _apply_camera_bounds(player: Node) -> void:
	var camera: Camera2D = player.get_node("Camera2D")
	var bounds := current_level.find_child("LevelBounds", true, false)

	if bounds:
		camera.limit_left = bounds.limit_left
		camera.limit_top = bounds.limit_top
		camera.limit_right = bounds.limit_right
		camera.limit_bottom = bounds.limit_bottom
	else:
		
		camera.limit_left = -10000000
		camera.limit_top = -10000000
		camera.limit_right = 10000000
		camera.limit_bottom = 10000000
func set_level_music(track: AudioStream, volume_db: float = 0.0):
	current_level_music = track
	current_level_music_volume = volume_db
	MusicManager.play(track, volume_db)

func change_room(scene: PackedScene, spawn: String) -> void:
	print("LevelManager received:", scene)
	await TransitionManager.close_eyes()
	load_level(scene, spawn)
	await TransitionManager.open_eyes()
