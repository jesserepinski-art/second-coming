class_name PartyBanter extends Resource

@export var banter_id: String = "" 
@export var required_party: Array[String] = [] 
@export var required_flag: String = "" 
@export var forbidden_flag: String = "" 
@export var repeatable: bool = false
@export var lines: Array[BanterLine] = []  
@export var weight: float = 1.0  
