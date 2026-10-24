class_name Util extends Node

static func get_enum_key_at_index(enumerator: Dictionary, index: int) -> String:
	return enumerator.keys()[index]

static func interweave_arrays(arr1: Array, arr2: Array) -> Array:
	var arr3: Array = []
	if arr1.size() != arr2.size():
		print("Error: Arrays must have matching sizes for interweave_arrays().")
	else:
		for i in range(arr1.size()):
			arr3.append(arr1[i])
			arr3.append(arr2[i])
	return arr3

static func choose(choices: Array):
	return choices[randi() % choices.size()]

static func choose_weighted(choices: Array):

	var n = 0
	var choices_size: int = choices.size()
	for i in range(1, choices_size, 2):
		if choices[i] <= 0:
			continue
		n += choices[i]
	
	n = randi() % int(n) 
	for i in range(1, choices_size, 2):
		if choices[i] <= 0:
			continue
		n -= choices[i]
		if n < 0:
			return choices[i - 1]
	return choices[0]
	


static func audio_play_varied_pitch(node: AudioStreamPlayer, base_range: float = 0.1) -> void:
	if !node:
		return
	var base: float = 1.0
	node.pitch_scale = randf_range(base - base_range, base + base_range)
	node.play()

static func audio_play_varied_pitch_2d(node: AudioStreamPlayer2D, base_range: float = 0.1, seek: float = 0.0) -> void:
	var base: float = 1.0
	node.pitch_scale = randf_range(base - base_range, base + base_range)
	node.play(seek)

static func set_keys_to_names(dict: Dictionary) -> void:
	var keys: Array = dict.keys()
	for key in keys:
		var value = dict[key]
		if value is Resource and "display_name" in value:
			value.display_name = key
		else:
			print("Skipping non-resource entry in dict: ", key, " (", value, ")")
static func array_random(arr: Array):
	return arr[randi() % arr.size()]

static func dictionary_random(dict: Dictionary):
	return dict.values()[randi() % dict.size()]

static func vec2_to_array(vec2: Vector2) -> Array:
	return [vec2.x, vec2.y]
	
static func array_to_vec2(array: Array) -> Vector2:
	return Vector2(array[0], array[1])

static func vec2_to_key(vec2: Vector2) -> String:
	return str(vec2.x) + "," + str(vec2.y)


static func unparse_vec2_dictionary(dict: Dictionary) -> Dictionary:
	var new_dict: Dictionary = {}
	var keys: Array = dict.keys()
	for key in keys:
		new_dict[vec2_to_key(key)] = dict[key]
	return new_dict

static func get_surrounding_cells(cell: Vector2, length: int = 3) -> Array:
	var surrounding_cells: Array = []
	var target_cell: Vector2
	
	length = int(max(length, 3)) 

	for y in length:
		for x in length:
			target_cell = cell + Vector2(x - 1, y - 1)

			if cell == target_cell:
				continue

			surrounding_cells.append(target_cell)
	
	return surrounding_cells
	

static func get_four_directions() -> Array:
	return [Vector2.UP, Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT]

static func timer_is_running(timer: Timer) -> bool:
	return !timer.is_stopped()

static func convert_int_array_to_bool_array(arr1: Array) -> Array:
	var arr2: Array = []
	for value in arr1:
		arr2.append(value > 0)
	return arr2

static func load_resources_to_dict(path: String, dict: Dictionary) -> void:
	var dir: DirAccess = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			elif file_name.ends_with(".tres"):
				var key: String = file_name.replace(".tres", "")
				dict[key] = load(path + file_name)
				dict[key].key = key
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
