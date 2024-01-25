extends Node2D

@export var PlayerScene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	round_start()
	move_players_to_spawn()
	seed(GameManager.seed)
	#spawn_players()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func move_players_to_spawn():
	var randomSpawnArray: Array[int]
	for i in GameManager.Players.size():
		randomSpawnArray.append(i)
	randomSpawnArray.shuffle()
	var index = 0
	for player in get_tree().get_nodes_in_group("Player"):
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoint"):
			if spawn.name == str(randomSpawnArray[index]):
				player.global_position = spawn.global_position
				player.velocity = Vector2(0,0)
		index += 1
	pass

func round_start():
	for bullet in get_tree().get_nodes_in_group("Bullet"): bullet.queue_free()
	for player in get_tree().get_nodes_in_group("Player"):
		player.revive.rpc()
		player.round_start.rpc()
