extends Node2D
class_name CloudLayer

@export var cloud_textures: Array[Texture2D] = []
@export var cloud_count := 6
@export var speed_range := Vector2(10.0, 25.0)
@export var sky_rect: Rect2 = Rect2(-960, -300, 1920, 200)  

var clouds: Array = []

func _ready() -> void:
	for i in range(cloud_count):
		var sprite := Sprite2D.new()
		sprite.texture = cloud_textures.pick_random()
		sprite.position = Vector2(
			randf_range(sky_rect.position.x, sky_rect.position.x + sky_rect.size.x),
			randf_range(sky_rect.position.y, sky_rect.position.y + sky_rect.size.y)
		)
		sprite.modulate.a = randf_range(0.5, 0.9)
		sprite.scale = Vector2.ONE * randf_range(0.7, 1.3)
		add_child(sprite)

		clouds.append({
			"sprite": sprite,
			"speed": randf_range(speed_range.x, speed_range.y)
		})

func _process(delta: float) -> void:
	var right_edge := sky_rect.position.x + sky_rect.size.x
	var left_edge := sky_rect.position.x

	for cloud in clouds:
		var sprite: Sprite2D = cloud.sprite
		sprite.position.x += cloud.speed * delta

		if sprite.position.x > right_edge + 100:
			sprite.position.x = left_edge - 100
