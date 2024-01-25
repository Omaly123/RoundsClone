extends Node

var Players = {}
var dead_players = {}
var winning_score = 2
var wins_to_end = 5
signal next_scene
signal winner
signal end
var seed
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

@rpc("any_peer")
func player_died(id):
	dead_players[id] = Players[int(str(id))]
	if dead_players.size() == Players.size() - 1:
		dead_players = {}
		for player in get_tree().get_nodes_in_group("Player"):
			if player.alive:
				Players[int(str(player.name))].score += 1
				if Players[int(str(player.name))].score >= winning_score:
					Players[int(str(player.name))].wins += 1
					for p in get_tree().get_nodes_in_group("Player"):
						Players[int(str(player.name))].score = 0
					if Players[int(str(player.name))].wins >= wins_to_end:
						end.emit(player)
						return
					winner.emit(player)
					return
		next_scene.emit()
	pass

