extends Control

@export var address = "127.0.0.1"
@export var port = 8910
var peer
var maps : Array
var pick_scene = preload("res://pick_scene.tscn")
var rng = RandomNumberGenerator.new()
var current_map
var current_map_number
# Called when the node enters the scene tree for the first time.

#new
@export var PlayerScene : PackedScene

func _ready():
	randomize()
	GameManager.next_scene.connect(change_map_signaled)
	GameManager.winner.connect(winner_signaled)
	GameManager.end.connect(end_signaled)
	maps = load_maps()
	
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#Called on server and clients
func peer_connected(id):
	print("Player connected:" + str(id))
	GameManager.seed = rng.seed
	set_seed_equal_to_host.rpc(rng.seed)
	seed(rng.seed)

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
			"score": 0,
			"wins":0
		}
	
	if multiplayer.is_server():
		for i in GameManager.Players:
			send_player_information.rpc(GameManager.Players[i].name, i)

@rpc("any_peer","call_local")
func start_game():
	#var scene = load("res://Levels/TestScene2.tscn").instantiate()
	var random_map_number = rng.randi_range(0,maps.size()-1)
	var scene = maps[random_map_number].instantiate()
	current_map_number = random_map_number
	get_tree().root.add_child(scene)
	print("map: " + scene.name)
	current_map = scene
	#self.hide()
	$Environment.hide()
	$SpawnPoints.hide()
	$BtHost.hide()
	$BtJoin.hide()
	$BtStart.hide()
	$LabelName.hide()
	$Name.hide()
	for p in get_tree().get_nodes_in_group("Player"):
		p.show()

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
	spawn_players.rpc()
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

@rpc()
func set_seed_equal_to_host(seed):
	rng.seed = seed
	GameManager.seed = seed
	seed(seed)

@rpc("call_local")
func spawn_players():
	var index = 0
	for i in GameManager.Players:
		var currentPlayer = PlayerScene.instantiate()
		currentPlayer.name = str(GameManager.Players[i].id)
		add_child(currentPlayer)
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoint"):
			if spawn.name == str(index):
				currentPlayer.global_position = spawn.global_position
		index += 1
		#print("spawned player " + currentPlayer.name)


func change_map_signaled():
	change_map.rpc()
	pass

func winner_signaled(winner):
	print("winner: " + str(winner))
	change_to_pick_scene.rpc()
	pass

func end_signaled(winner):
	print("Game Over. winner: " + str(winner))
	pass


#@rpc("call_local")
@rpc("call_local", "any_peer")
func change_map():
	if current_map != null:
		for bullet in get_tree().get_nodes_in_group("Bullet"): bullet.queue_free()
		current_map.queue_free()
		
		var random_map_number = rng.randi_range(0,maps.size()-1)
		while current_map_number == random_map_number: #& maps.size() != 1:
			random_map_number = rng.randi_range(0,maps.size()-1)
		
		print("seed used: " + str(rng.seed))
		var scene = maps[random_map_number].instantiate()
		get_tree().root.add_child(scene)
		print("map: " + scene.name)
		current_map = scene
		
		for player in get_tree().get_nodes_in_group("Player"):
			player.revive.rpc()
			player.round_start.rpc()
		pass

@rpc("call_local", "any_peer")
func change_to_pick_scene():
	if current_map != null:
		for bullet in get_tree().get_nodes_in_group("Bullet"): bullet.queue_free()
		current_map.queue_free()
		
		
		var scene = pick_scene.instantiate()
		get_tree().root.add_child(scene)
		current_map = scene
		pass

func _on_change_map_button_down():
	change_map.rpc()
	pass # Replace with function body.



func _on_nametest_button_down():
	for player in GameManager.Players:
		print("player id " + str(player) + "\n" + "name " + str(GameManager.Players[player].name) + "\n" + "id " + str(GameManager.Players[player].id))
	pass # Replace with function body.
