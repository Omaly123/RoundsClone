extends Control

@export var address = "127.0.0.1"
@export var port = 8910
var peer
var maps : Array
var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.

#new
@export var PlayerScene : PackedScene

func _ready():
	randomize()
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	maps = load_maps()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#Called on server and clients
func peer_connected(id):
	print("Player connected:" + str(id))
	set_seed_equal_to_host.rpc(rng.seed)

#Called on server and clients
func peer_disconnected(id):
	print("Player disconnected:" + str(id))

#Called only from Clients
func connected_to_server():
	print("Connected to server")
	send_player_information.rpc_id(1,$Name.text, multiplayer.get_unique_id())

#Called only from Clients
func connection_failed():
	print("Could not connect")
	
@rpc("any_peer")
func send_player_information(name, id):
	if !GameManager.Players.has(id):
		GameManager.Players[id] = {
			"name": name,
			"id": id,
			"score": 0
		}
	
	if multiplayer.is_server():
		for i in GameManager.Players:
			send_player_information.rpc(GameManager.Players[i].name, i)
			
			

@rpc("any_peer","call_local")
func start_game():
	#var scene = load("res://Levels/TestScene2.tscn").instantiate()
	var random_map_number = rng.randi_range(0,maps.size()-1)
	print(random_map_number)
	var scene = maps[random_map_number].instantiate()
	get_tree().root.add_child(scene)
	print(scene.name)
	self.hide()

func _on_bt_host_button_down():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 8)
	if error != OK:
		print("cannot host: " + str(error))
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players")
	send_player_information($Name.text, multiplayer.get_unique_id())
	
	
	pass # Replace with function body.


func _on_bt_join_button_down():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	pass # Replace with function body.


func _on_bt_start_button_down():
	start_game.rpc()
	pass # Replace with function body.


func load_maps() -> Array:
	var loaded_maps : Array[PackedScene]
	var dir = DirAccess.open("res://Levels/")  
	dir.list_dir_begin()  
	var file_name = dir.get_next()  
	while file_name != "":
		var file_path = "res://Levels/" + "/" + file_name  
		if file_name.ends_with(".tscn"):
			loaded_maps.append(load(file_path))
		file_name = dir.get_next()  
	return loaded_maps
	pass

@rpc
func set_seed_equal_to_host(seed):
	rng.seed = seed



func _on_test_player_spawn_button_down():
		#new
	var index = 0
	for i in GameManager.Players:
		var currentPlayer = PlayerScene.instantiate()
		currentPlayer.name = str(GameManager.Players[i].id)
		add_child(currentPlayer)
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoint"):
			if spawn.name == str(index):
				currentPlayer.global_position = spawn.global_position
		index += 1
	pass # Replace with function body.
