extends Node

const MAX_PARTY_SIZE := 4

var items: Dictionary = {}
var party: Array[BattleActor] = []
var gold: int = 0
var flags: Dictionary = {}
var rooms: Dictionary = {}
var item_inventory: Inventory = Inventory.new()
var equipment_inventory: Array[Equipment] = []
var reserve: Dictionary = {}

const DAMA_DATA: BattleActor = preload("res://Players/dama.tres")
const PROVIDENCE_DATA: BattleActor = preload("res://Players/providence.tres")
const AMANIRENAS_DATA: BattleActor = preload("res://Players/Amanirenas.tres")
const ASMODEUS_DATA: BattleActor = preload("res://Players/AsmodeusAlly.tres")
const KAMARI_DATA: BattleActor = preload("res://Players/Kamari.tres")
const ACESO_DATA: BattleActor = preload("res://Players/Aceso.tres")

func _process(_delta: float) -> void:
	pass 
func _ready() -> void:
	load_resources_to_dict("res://Items/", items)
	Util.set_keys_to_names(items)
	start_new_game()

func start_new_game() -> void:
	party.clear()
	add_party_member(DAMA_DATA)

signal party_changed

func add_party_member(base_data: BattleActor) -> bool:
	if party.size() >= MAX_PARTY_SIZE:
		push_warning("Party is full, can't add " + base_data.name)
		return false
	var instance: BattleActor = base_data.copy()
	party.append(instance)
	party_changed.emit()
	return true

func remove_party_member(actor: BattleActor) -> void:
	party.erase(actor)

func use_item(item: Item, target: BattleActor) -> void:
	if item.heal > 0:
		target.healhurt(item.heal)
	if item.power > 0:
		target.healhurt(-item.power)
	if item.status_effect:
		target.add_status(item.status_effect)
	item_inventory.remove_item(item)

func load_resources_to_dict(path: String, dict: Dictionary) -> void:
	var dir: DirAccess = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				dict[file_name.replace(".tres", "")] = load(path + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
func is_in_party(actor_name: String) -> bool:
	for a in party:
		if a.name == actor_name:
			return true
	return false
func recruit(base_data: BattleActor) -> bool:
	if party.size() >= MAX_PARTY_SIZE:
		return false
	var actor: BattleActor = reserve.get(base_data.name, null)
	if actor:
		reserve.erase(base_data.name)
	else:
		actor = base_data.copy()
	party.append(actor)
	party_changed.emit()
	return true

func dismiss(actor: BattleActor) -> void:
	if actor == party[0]:
		return  
	party.erase(actor)
	reserve[actor.name] = actor
	party_changed.emit()
