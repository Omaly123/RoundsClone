extends Node2D

var player
var cards : Array[Resource]
# Called when the node enters the scene tree for the first time.
func _ready():
	#$MultiplayerSynchronizer.set_multiplayer_authority(str(player.name).to_int())
	cards = load_cards("res://Cards/")
	
	
	$Control/TextureButton.texture_normal = cards[0].texture
	$Control/TextureButton.texture_normal = cards[1].texture
	$Control/TextureButton.texture_normal = cards[2].texture
	$Control/TextureButton.texture_normal = cards[3].texture
	$Control/TextureButton.texture_normal = cards[4].texture
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_cards(path) -> Array:
	var loaded_cards : Array[Resource]
	var dir = DirAccess.open(path)  
	dir.list_dir_begin()  
	var file_name = dir.get_next()  
	while file_name != "":
		var file_path = path + "/" + file_name  
		if file_name.ends_with(".tres"):
			loaded_cards.append(load(file_path))
		file_name = dir.get_next()  
	return loaded_cards
	pass





'func load_scenes(path) -> Array:
	var loaded_scenes : Array[PackedScene]
	var dir = DirAccess.open(path)  
	dir.list_dir_begin()  
	var file_name = dir.get_next()  
	while file_name != "":
		var file_path = path + "/" + file_name  
		if file_name.ends_with(".tscn"):
			loaded_scenes.append(load(file_path))
		file_name = dir.get_next()  
	return loaded_scenes
	pass'
