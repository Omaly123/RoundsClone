extends Resource

class_name Card

var player

@export var card_name: String
@export var card_abbreviation: String
enum rarity_value {common, uncommon, rare, legendary}
@export var rarity: rarity_value
@export var texture: Texture = load("res://Assets/TestCardBackround.png")
@export var card_text: String

#player stats:
@export var damage = 0
@export var damage_percent = 0
@export var health = 0
@export var health_percent = 0
@export var attack_cooldown_seconds = 0
@export var attack_cooldown_percent = 0
@export var block_cooldown_seconds = 0
@export var block_cooldown_percent = 0
@export var reload_cooldown_percent = 0
@export var reload_cooldown_seconds = 0
@export var ammo = 0
@export var speed = 0
@export var speed_percent = 0
@export var bullet_speed = 0
@export var bullet_speed_percent = 0
@export var bounces = 0

#original player stats:
var original_damage
var original_health
var original_attack_cooldown
var original_block_cooldown
var original_reload_cooldown
var original_ammo
var original_speed
var original_bullet_speed
var original_bounces
func _ready():
	original_damage = player.damage
	original_health = player.health
	original_attack_cooldown = player.attack_cooldown
	original_block_cooldown = player.block_cooldown
	original_reload_cooldown = player.reload_cooldown
	original_ammo = player.max_ammo
	original_speed = player.speed
	original_bullet_speed = player.bullet_speed
	original_bounces = player.bounces
	pass 

func _process(delta):
	pass

func save_old_stats():
	original_damage = player.damage
	original_health = player.health
	original_attack_cooldown = player.attack_cooldown
	original_block_cooldown = player.block_cooldown
	original_reload_cooldown = player.reload_cooldown
	original_ammo = player.max_ammo
	original_speed = player.speed
	original_bullet_speed = player.bullet_speed
	original_bounces = player.bounces

#this function is for adding simple effects, that are managed in the player script through variables like bounces or damage
func add_effects(player):
	player.damage += damage
	player.damage = player.damage + (player.damage/100)*damage_percent
	player.health += health
	player.health = player.health + (player.health/100)*health_percent
	player.attack_cooldown += attack_cooldown_seconds*60
	player.attack_cooldown = original_attack_cooldown + (original_attack_cooldown/100)*attack_cooldown_percent
	player.block_cooldown += block_cooldown_seconds*60
	player.block_cooldown = player.block_cooldown + (player.block_cooldown/100)*block_cooldown_percent
	player.reload_cooldown += reload_cooldown_seconds*60
	player.reload_cooldown = player.reload_cooldown + (player.reload_cooldown/100)*reload_cooldown_percent
	player.max_ammo += ammo
	player.speed += speed
	player.bullet_speed += bullet_speed
	player.bullet_speed = player.bullet_speed + (player.bullet_speed/100)*bullet_speed
	player.bounces += bounces
	pass

#this function is for removing the effects of the add_effects function. To prevent errors all Cards added after this one should probably also be removed first
func remove_effects():
	player.damage = original_damage
	player.health = original_health
	player.attack_cooldown = original_attack_cooldown
	player.block_cooldown = original_block_cooldown
	player.reload_cooldown = original_reload_cooldown
	player.max_ammo = original_ammo
	player.speed = original_speed
	player.bullet_speed = original_bullet_speed
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
func hit_effect(player, damage):
	pass

#the effect for when the player reloads his weapon
func reload_effect():
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

