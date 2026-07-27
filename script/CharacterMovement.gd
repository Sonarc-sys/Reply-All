extends CharacterBody2D

enum Role { CEO, MANAGER, INTERN }
@export var role: Role = Role.INTERN

var speed: float = 100.0
var wait_time: float = 2.0 
var is_moving: bool = false
var target_position: Vector2


var office_center: Vector2
var patrol_angle: float = 0.0

@onready var movement_timer: Timer = Timer.new()

func _ready() -> void:
	add_child(movement_timer)
	movement_timer.timeout.connect(_on_timer_timeout)
	movement_timer.one_shot = true
	office_center = global_position 
	
	setup_archetype()

func setup_archetype() -> void:
	match role:
		Role.CEO:
			speed = 30.0
			wait_time = 8.0
		Role.MANAGER:
			speed = 65.0
			wait_time = 1.5
		Role.INTERN:
			speed = 180.0 
			wait_time = 0.3
			
	movement_timer.start(wait_time)

func _on_timer_timeout() -> void:
	match role:
		Role.CEO:
			if randf() > 0.75:
				pick_random_target(40.0)
			else:
				is_moving = false
				movement_timer.start(wait_time)
				
		Role.MANAGER:
			pick_circular_target(120.0) 
			
		Role.INTERN:
			pick_random_target(350.0)

func pick_random_target(radius: float) -> void:
	var random_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	var random_dist = randf_range(20.0, radius)
	
	target_position = global_position + (random_dir * random_dist)
	is_moving = true

func pick_circular_target(radius: float) -> void:
	patrol_angle += PI / 3
	
	var offset = Vector2(cos(patrol_angle), sin(patrol_angle)) * radius
	target_position = office_center + offset
	is_moving = true

func _physics_process(delta: float) -> void:
	if not is_moving:
		return
		
	var direction = global_position.direction_to(target_position)
	velocity = direction * speed
	move_and_slide()
	if global_position.distance_to(target_position) < 5.0:
		is_moving = false
		velocity = Vector2.ZERO
		movement_timer.start(wait_time)
