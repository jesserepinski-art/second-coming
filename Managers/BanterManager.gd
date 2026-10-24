extends Node

var banter_pool: Array[PartyBanter] = []
var check_interval := 5
var trigger_chance := 1
var _timer := 0.0
var active := false

func _ready() -> void:
	_load_banter_pool("res://Banter/")

func _load_banter_pool(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var resource := load(path + file_name)
				if resource is PartyBanter:
					banter_pool.append(resource)
			file_name = dir.get_next()
	else:
		print("Could not open banter folder: ", path)
func _process(delta: float) -> void:
	if not active:
		return
	_timer += delta
	if _timer >= check_interval:
		_timer = 0.0
		_try_trigger_banter()

func _try_trigger_banter() -> void:
	if BattleManager.current_battle:
		return
	if randf() > trigger_chance:
		return

	var eligible: Array[PartyBanter] = []
	for banter in banter_pool:
		if _is_eligible(banter):
			eligible.append(banter)

	if eligible.is_empty():
		return

	var chosen := _weighted_pick(eligible)
	_play_banter(chosen)

func _is_eligible(banter: PartyBanter) -> bool:
	if not banter.repeatable and StoryFlags.has_flag("banter_seen_" + banter.banter_id):
		return false
	if banter.required_flag != "" and not StoryFlags.has_flag(banter.required_flag):
		return false
	if banter.forbidden_flag != "" and StoryFlags.has_flag(banter.forbidden_flag):
		return false

	var party_names: Array[String] = []
	for actor in Data.party:
		party_names.append(actor.name)

	for required_name in banter.required_party:
		if not party_names.has(required_name):
			return false

	return true

func _weighted_pick(options: Array[PartyBanter]) -> PartyBanter:
	var total := 0.0
	for o in options:
		total += o.weight
	var roll := randf() * total
	for o in options:
		roll -= o.weight
		if roll <= 0.0:
			return o
	return options.back()

func _play_banter(banter: PartyBanter) -> void:
	StoryFlags.set_flag("banter_seen_" + banter.banter_id)

	for line: BanterLine in banter.lines:
		var speaker_actor := _find_actor_by_name(line.speaker)
		var portrait: Texture2D = speaker_actor.portrait if speaker_actor else null
		await Globals.banter_box.play_line(line.speaker, line.text, portrait)
		
func _find_actor_by_name(actor_name: String) -> BattleActor:
	for actor in Data.party:
		if actor.name == actor_name:
			return actor
	return null
func debug_force_play(banter_id: String) -> void:
	for banter in banter_pool:
		if banter.banter_id == banter_id:
			_play_banter(banter)
			return
	print("No banter found with id: ", banter_id)
