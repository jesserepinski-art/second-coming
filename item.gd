class_name Item
extends Resource

signal updated(quantity: int)

enum ItemType {
	ITEM,
	MAGIC
}

enum TargetType {
	ENEMY,
	ALLY,
	SELF,
	ALL_ENEMIES,
	ALL_ALLIES
}


@export var name: String = ""


@export var display_name: String = ""

@export_multiline var description: String = ""

@export var type: ItemType = ItemType.ITEM
@export var use_sound: AudioStream

@export var icon: AtlasTexture = null

@export var quantity: int = 1:
	set(value):
		quantity = value
		updated.emit(quantity)

@export var stackable: bool = true
@export var value: int = 0
@export_range(0.0, 3.0, 0.05) var power_scaling: float = 0.0  
@export_range(0.0, 3.0, 0.05) var heal_scaling: float = 0.0   

@export var mp_cost: int = 0
@export var target: TargetType = TargetType.ENEMY

@export var power: int = 0
@export var heal: int = 0


@export var attack_video: VideoStream = null
@export var effect_video: VideoStream = null

@export var cast_sound: AudioStream
@export var impact_sound: AudioStream
@export var status_effect: StatusEffect
@export_range(0, 100)
var status_chance: int = 100

func set_name_custom(n: String) -> void:
	name = n


func duplicate_custom() -> Item:
	
	var dup := self.duplicate(true) as Item
	
	if dup:
		dup.quantity = self.quantity
		
		if "name" in self:
			dup.name = self.name
			
	return dup
