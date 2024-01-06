extends CharacterBody2D


@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export var JUMP_FORCE_UP = 5
@export var JUMP_FORCE_DOWN = 10
var Cards = {}

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var blocking = 0
@export var attackCD = 60 #60 delta is 1sec
var attackCDTimer = 300
@export var blockCD = 60 #60 delta is 1sec
var blockCDTimer = 0
var cards : Array
@export var damage = 30
@export var bullet_speed = 600
@export var bounces = 0
@export var max_ammo = 3
var ammo = 3
@export var reloadCD = 300
var reloadCDTimer = 600
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

func _process(delta):
	$ProgressBar.max_value = max_health
	$ProgressBar.value = health
	if health <= 0: death.rpc()
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		$GunRotation.look_at(get_viewport().get_mouse_position())
		if Input.is_action_just_pressed("leftclick") && attackCDTimer <= 0:
			fire.rpc()
		if Input.is_action_just_pressed("rightclick") && blockCDTimer <= 0:
			block_start.rpc()
		if blocking >= 1:
			blocking -=1
			if blocking == 0:
				block_end.rpc()
	if blocking == 0: $Block.visible = false
	
	#reloading:
	if reloadCDTimer > 0 && chamber.size() < max_ammo: reloadCDTimer -= 1
	if reloadCDTimer == 0: reload.rpc()
	#cooldowns:
	if attackCDTimer > 0: attackCDTimer -= 1
	if blockCDTimer > 0: blockCDTimer -= 1
	poison_tick()
	pass


func _physics_process(delta):
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		# Add the gravity.
		if not is_on_floor():
			if is_on_wall() && velocity.y > 0:
				velocity.y += gravity * delta *0.2
			else:
				velocity.y += gravity * delta
			if Input.is_action_pressed("bt_w") or Input.is_action_pressed("space"):
				velocity.y -= JUMP_FORCE_UP
			if Input.is_action_pressed("bt_s"):
				velocity.y += JUMP_FORCE_DOWN
		
		# Handle Jump.
		if Input.is_action_just_pressed("ui_accept") and(is_on_floor() or is_on_wall()):
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction = Input.get_axis("bt_a", "bt_d")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()

@rpc("any_peer","call_local")
func fire():
	if chamber.size() > 0:
		var b = bullet.instantiate()
		b.global_position = $GunRotation/BulletSpawn.global_position
		b.global_rotation = $GunRotation/BulletSpawn.global_rotation
		#b.velocity = bullet_speed * b.direction
		b.SPEED = bullet_speed
		b.shooter = $"."
		b.damage = damage
		b.bounces = bounces
		#print($GunRotation/BulletSpawn.rotation)
		get_tree().root.add_child(b)
		chamber[chamber.size()-1].queue_free()
		chamber.remove_at(chamber.size()-1)
		attackCDTimer = attackCD
		for i in cards:
			cards[i].shoot_effect()

@rpc("any_peer","call_local")
func hit(damage, shooter):
	for i in cards:
		cards[i].got_hit_effect(shooter)
	take_damage(damage)
	pass

func take_damage(damage:int):
	for i in cards:
		cards[i].damage_effect(damage)
	health -= damage
	pass

@rpc("any_peer","call_local")
func block_start():
	for i in cards:
		cards[i].block_start_effect()
	$Block.visible = true
	blocking = 30
	pass

@rpc("any_peer","call_local")
func block_end():
	for i in cards:
		cards[i].block_end_effect()
	pass

@rpc("any_peer","call_local")
func reload():
	print("reload")
	for i in cards:
		cards[i].reload_effect()
	for i in max_ammo:
		if chamber.size() <= i:
			var b = chamber_bullet.instantiate()
			chamber.append(b)
			b.position = $GunRotation/BulletSpawn.position + Vector2(5*(i%3),-7-5*floor(i/3))
			b.rotation = $GunRotation/BulletSpawn.rotation
			#print($GunRotation/BulletSpawn.rotation)
			$GunRotation.add_child(b)
	reloadCDTimer = reloadCD
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
	for i in cards:
		cards[i].death_effect()
	died.emit()
	$AnimatedSprite2D.hide()
	$CollisionShape2D.disabled = true
	$GunRotation/Gun.hide()
	pass

func add_card(card):
	add_child(card)
	Cards.append(card)
	card.player = $"."
	card.pick_effect()
	card.add_effects()
