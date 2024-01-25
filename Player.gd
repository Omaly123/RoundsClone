extends CharacterBody2D


@export var speed = 300.0
@export var jump_velocity = -400.0
@export var jump_force_up = 5
@export var jump_force_down = 10
var alive = true
var cards : Array[Resource]
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var attack_cooldown = 60 #60 delta is 1sec
var attack_cooldown_timer = 300
@export var block_cooldown = 60 #60 delta is 1sec
var block_cooldown_timer = 0
var blocking = 0
const MINIMUM_BLOCK_COOLDOWN = 35
var damage = 30
@export var bullet_speed = 600
@export var bounces = 0
@export var max_ammo = 3
var ammo = 3
@export var reload_cooldown = 600
var reload_cooldown_timer = 600
var chamber : Array
var health = 100
var poison_stacks = 0
var poison_timer = 0

@export var max_health = 100
@export var bullet: PackedScene
@export var chamber_bullet: PackedScene
signal died

func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	
	#cards.append(load("res://Cards/Crit.tres"))
	#cards[0].player = $"."
	#cards[0].save_old_stats()
	#cards[0].add_effects($".")

func _process(delta):
	if alive:
		$ProgressBar.max_value = max_health
		$ProgressBar.value = health
		if health <= 0: death.rpc()
		if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
			$GunRotation.look_at(get_viewport().get_mouse_position())
			if Input.is_action_just_pressed("leftclick") && attack_cooldown_timer <= 0:
				fire.rpc()
			if Input.is_action_just_pressed("rightclick") && block_cooldown_timer <= 0:
				block_start.rpc()
				block_cooldown_timer = max(block_cooldown,MINIMUM_BLOCK_COOLDOWN)
			if blocking >= 0:
				blocking -=1
			if blocking == 0:
				block_end.rpc()
		if blocking == 0: $Block.visible = false
		
		#reloading:
		if reload_cooldown_timer > 0 && chamber.size() < max_ammo: reload_cooldown_timer -= 1
		if reload_cooldown_timer == 0: reload.rpc()
		#cooldowns:
		if attack_cooldown_timer > 0: attack_cooldown_timer -= 1
		if block_cooldown_timer > 0: block_cooldown_timer -= 1
		poison_tick()
	pass


func _physics_process(delta):
	if alive:
		if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
			# Add the gravity.
			if not is_on_floor():
				if is_on_wall() && velocity.y > 0:
					velocity.y += gravity * delta *0.2
				else:
					velocity.y += gravity * delta
				if Input.is_action_pressed("bt_w") or Input.is_action_pressed("space"):
					velocity.y -= jump_force_up
				if Input.is_action_pressed("bt_s"):
					velocity.y += jump_force_down
			
			# Handle Jump.
			if Input.is_action_just_pressed("space") and(is_on_floor() or is_on_wall()):
				velocity.y = jump_velocity

			# Get the input direction and handle the movement/deceleration.
			# As good practice, you should replace UI actions with custom gameplay actions.
			var direction = Input.get_axis("bt_a", "bt_d")
			if direction:
				velocity.x = direction * speed
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
			move_and_slide()

@rpc("any_peer","call_local")
func fire():
	if chamber.size() > 0:
		var b = bullet.instantiate()
		b.global_position = $GunRotation/BulletSpawn.global_position
		b.global_rotation = $GunRotation/BulletSpawn.global_rotation
		#b.velocity = bullet_speed * b.direction
		b.speed = bullet_speed
		b.shooter = $"."
		b.damage = damage
		b.bounces = bounces
		b.cards = cards
		#print($GunRotation/BulletSpawn.rotation)
		get_tree().root.add_child(b)
		chamber[chamber.size()-1].queue_free()
		chamber.remove_at(chamber.size()-1)
		attack_cooldown_timer = attack_cooldown
		for card in cards:
			card.shoot_effect()

#@rpc("any_peer","call_local")
func hit(damage, shooter):
	for card in cards:
		card.got_hit_effect(shooter)
	take_damage(damage)
	pass

func take_damage(damage:int):
	for card in cards:
		card.damage_effect(damage)
	health -= damage
	pass

@rpc("any_peer","call_local")
func block_start():
	for card in cards:
		card.block_start_effect()
	$Block.visible = true
	blocking = 30
	pass

@rpc("any_peer","call_local")
func block_end():
	blocking = 0
	for card in cards:
		card.block_end_effect()
	$Block.visible = false
	pass

@rpc("any_peer","call_local")
func reload():
	print("reload")
	for card in cards:
		card.reload_effect()
	for i in max_ammo:
		if chamber.size() <= i:
			var b = chamber_bullet.instantiate()
			chamber.append(b)
			b.position = $GunRotation/BulletSpawn.position + Vector2(5*(i%3),-7-5*floor(i/3))
			b.rotation = $GunRotation/BulletSpawn.rotation
			#print($GunRotation/BulletSpawn.rotation)
			$GunRotation.add_child(b)
	reload_cooldown_timer = reload_cooldown
	pass
	
func poison_tick():
	if poison_stacks > 0:
		take_damage(poison_stacks)
		poison_stacks = floor(poison_stacks*0.5)
	if poison_timer > 0: poison_timer -= 1
	if poison_timer == 0: poison_stacks = 0
	pass

@rpc("any_peer","call_local")
func death():
	for card in cards:
		card.death_effect()
	if health <= 0:
		#died.emit()
		GameManager.player_died.rpc($".".name)
		$".".hide()
		$CollisionShape2D.disabled = true
		alive = false
	pass

@rpc("any_peer","call_local")
func revive():
	$".".show()
	$CollisionShape2D.disabled = false
	alive = true
	health = max_health
	block_cooldown_timer = 0
	poison_timer = 0
	poison_stacks = 0
	ammo = max_ammo
	pass

@rpc("any_peer","call_local")
func add_card(card):
	#add_child(card)
	cards.append(card)
	card.player = $"."
	card.pick_effect()
	card.add_effects()

@rpc("any_peer","call_local")
func round_start():
	$".".show()
	health = max_health
	ammo = max_ammo
	poison_stacks = 0
	poison_timer = 0
	block_cooldown_timer = 0
	attack_cooldown_timer = 600
	
