extends CharacterBody2D


var SPEED = 600.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction : Vector2
var bounces = 0
var old_velocity : Vector2
var damage = 10
var shooter
var gravitx_multiplier = 0.5
var noDoubleCollision = false
var effects : Array
func _ready():
	direction = Vector2(1,0).rotated(rotation)
	velocity = SPEED * direction
	shooter.died.connect(shooter_died)

func _physics_process(delta):
	# Add the gravity.
	direction = velocity.normalized()
	rotation = direction.angle()
	
	var doubleCollision = false
	if noDoubleCollision: 
		noDoubleCollision = false
		doubleCollision = true
		
	if not is_on_floor():
		velocity.y += gravity * delta * gravitx_multiplier
		pass
	var collision_info = move_and_collide(velocity*delta)
	if collision_info:
		var collider = collision_info.get_collider()
		if collider != null && collider.has_method("fire") :
			if collider.blocking >=1 :
				velocity = velocity.bounce(collision_info.get_normal())
			else: if collider.blocking ==0:
				collider.hit.rpc(damage, effects)
				queue_free()
		else: if bounces == 0:
			WallHit(collision_info)
			queue_free()
		else: if bounces > 0 : 
			bounces-=1
			WallHit(collision_info)
			velocity = velocity.bounce(collision_info.get_normal())
func WallHit(collision):
	pass

func shooter_died():
	queue_free()
	pass

