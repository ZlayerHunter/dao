extends CharacterBody2D

# Called every frame. 'delta' is the elapsed time since the previous frame.

var chase = false
var speed = 100
@onready var anim = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	var player = $"../../Player/Player"
	var direction = (player.position - self.position).normalized()

	if chase:
		velocity.x = direction.x * speed
		anim.play("run")
		anim.flip_h = direction.x < 0
	else:
		velocity.x = 0
		anim.play("idle")
	
	move_and_slide()


func _on_detector_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
	if body.name == "Player":
		chase = true

func _on_detector_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
	if body.name == "Player":
		chase = false
