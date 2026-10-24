class_name SaveData extends Resource

@export var version := 1
@export var level_path := ""
@export var player_position := Vector2.ZERO
@export var gold := 0
@export var party: Array[BattleActor] = []
@export var items: Array[Item] = []
@export var equipment: Array[Equipment] = []
@export var flags: Dictionary = {}
@export var active_quests: Array[String] = []
@export var quest_steps: Dictionary = {}
@export var location_name: String 
@export var saved_at: String 
@export var playtime: float
var reserve: Dictionary = {}
