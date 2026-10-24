extends Node

var enemies: Array = []
var enemy_node: Node = null
var return_scene: String = ""

var battle_music: AudioStream = null
var battle_background: PackedScene = null  
var ambience: AudioStream = null
var battle_music_volume: float = 0.0
var won := false
