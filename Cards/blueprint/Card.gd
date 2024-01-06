extends Resource

class_name Card

var Player

@export var card_name: String
@export var card_texture: Texture
@export var card_text: String

func _ready():
	pass 

func _process(delta):
	pass

#this function is for adding simple effects, that are managed in the player script through variables like bounces or damage
func add_effects():
	pass

#this function is for removing the effects of the add_effects function. To prevent errors all Cards added after this one should probably also be removed first
func remove_effects():
	pass

#the effect for when this card is added to a player
func pick_effect():
	pass

#the effect for when the player shoots his weapon. This is triggered before the bullet is instantiated
func shoot_effect():
	pass

#the effect for when the player blocks
func block_start_effect():
	pass

#the effect for when the block ends
func block_end_effect():
	pass

#the effect for when a bullet hits an enemy player
func hit_effect(player):
	pass

#the effect for when a bullet is blocked by an enemy player
func hit_blocked_effect(player):
	pass

#the effect for when the player reaches 0 hp. This effect is triggered before the player dies
func death_effect():
	pass

#the effect for when the player is hit by a bullet. The player variable is the enemy player
func got_hit_effect(player):
	pass

#the effect for when the player takes damage
func damage_effect(damage):
	pass

#the effect for when a bullet collides with a wall and bounces
func wall_hit_effect(collision_info):
	pass

#the effect for when a bullet hits a wall and is destroyed
func last_wall_hit_effect(collision_info):
	pass

