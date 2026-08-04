extends CharacterBody2D

signal issue_clicked(employee)

@onready var name_label = $UI/NameLabel
@export var employee_name = "Employee"

# Updated enum to reflect your current roles
@export_enum(
	"CEO",
	"Manager",
	"Secretary",
	"Office Worker",
	"Intern"
) var employee_type = "Office Worker"

@export var walking_speed = 30

# Role Configuration for patience, drain rate, movement probability, and speed
const ROLE_CONFIG = {
	"CEO":           { "patience": 120, "drain": 1.0, "walk_chance": 0.20, "speed": 15 },
	"Manager":       { "patience": 110, "drain": 1.1, "walk_chance": 0.30, "speed": 17 },
	"Secretary":     { "patience": 100, "drain": 1.0, "walk_chance": 0.25, "speed": 15 },
	"Office Worker": { "patience": 100, "drain": 1.0, "walk_chance": 0.40, "speed": 18 },
	"Intern":        { "patience": 130, "drain": 0.7, "walk_chance": 0.50, "speed": 22 },
}
const DEFAULT_CFG = { "patience": 100, "drain": 1.0, "walk_chance": 0.10, "speed": 18 }

var _cfg: Dictionary = {}

var direction_ofmovement = Vector2.ZERO
var timer_movement = 0.0

var has_issue = false
@onready var patience_bar = $UI/PatienceBar
var patience = 100
var current_issue: CyberIssue
var escalated = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	name_label.text = employee_name
	GameManager.register_employee(self)
	_cfg = ROLE_CONFIG.get(employee_type, DEFAULT_CFG)
	patience = _cfg["patience"]
	$UI/Exclamation.visible = false
	timer_movement = randf_range(2.0, 8.0)
	
	_update_animation()

func _process(delta):
	if has_issue and !escalated:
		var excl = $UI/Exclamation
		if excl.visible:
			var pulse = 1.0 + sin(Time.get_ticks_msec() * 0.01) * 0.1
			excl.scale = Vector2(pulse, pulse)
		patience -= current_issue.urgency * 10.0 * delta * _cfg["drain"]
		patience_bar.value = clamp(patience, 0, 100)
		if patience <= 0:
			escalate()

func _physics_process(delta):
	timer_movement -= delta
	if timer_movement <= 0:
		if randf() < _cfg["walk_chance"]:
			var rand_angle = randf() * TAU
			direction_ofmovement = Vector2(cos(rand_angle), sin(rand_angle))
			timer_movement = randf_range(1.0, 2.5)
		else:
			direction_ofmovement = Vector2.ZERO
			timer_movement = randf_range(4.0, 10.0)

	velocity = direction_ofmovement * _cfg["speed"]
	move_and_slide()

	# Keep NPC within safe walkable map bounds
	var clamped = Vector2(
		clamp(global_position.x, 40.0, 950.0),
		clamp(global_position.y, 175.0, 890.0)
	)
	if clamped != global_position:
		global_position = clamped
		direction_ofmovement = Vector2.ZERO
		timer_movement = randf_range(2.0, 5.0)

	_update_animation()

func _update_animation():
	if sprite == null or sprite.sprite_frames == null:
		return

	# Map "Office Worker" -> "worker", others -> lowercase with underscores
	var role_key: String = ""
	match employee_type:
		"Office Worker":
			role_key = "worker"
		_:
			role_key = employee_type.to_lower().replace(" ", "_")

	var is_walking = direction_ofmovement.length() > 0.1
	var anim_state = "walk" if is_walking else "default"
	
	# Constructs target name (e.g., "worker_default", "ceo_walk")
	var target_anim = "%s_%s" % [role_key, anim_state]

	# Flip sprite horizontally according to horizontal movement direction
	if is_walking:
		if direction_ofmovement.x < 0:
			sprite.flip_h = true
		elif direction_ofmovement.x > 0:
			sprite.flip_h = false

	# Play animation if available in SpriteFrames, with fallback
	if sprite.sprite_frames.has_animation(target_anim):
		if sprite.animation != target_anim:
			sprite.play(target_anim)
	elif sprite.sprite_frames.has_animation(anim_state):
		if sprite.animation != anim_state:
			sprite.play(anim_state)

func show_lockdown_alert():
	var excl = $UI/Exclamation
	excl.visible = true
	excl.scale = Vector2(1.8, 1.8)
	excl.add_theme_color_override("font_color", Color(0.95, 0.05, 0.05))
	excl.add_theme_font_size_override("font_size", 80)

func hide_lockdown_alert():
	var excl = $UI/Exclamation
	excl.visible = false
	excl.scale = Vector2(1.0, 1.0)
	excl.add_theme_color_override("font_color", Color(1.0, 0.15, 0.10))
	excl.add_theme_font_size_override("font_size", 64)
	if has_issue and not escalated:
		excl.visible = true

func interact():
	if GameManager.lockdown_active:
		issue_clicked.emit(self)
		return
	if has_issue:
		issue_clicked.emit(self)

func lockdown_clear():
	if not GameManager.lockdown_active:
		return
	var root = get_tree().get_root()
	for child in root.get_children():
		for sub in child.get_children():
			if sub.name == "LockdownEvent":
				sub.notify_npc_cleared(self)
				return
			for subsub in sub.get_children():
				if subsub.name == "LockdownEvent":
					subsub.notify_npc_cleared(self)
					return

func create_issue(issue: CyberIssue):
	has_issue = true
	escalated = false
	current_issue = issue
	patience = _cfg["patience"]
	var excl = $UI/Exclamation
	excl.visible = true
	excl.scale = Vector2.ZERO
	var tw = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(excl, "scale", Vector2(1, 1), 0.5)
	GameManager.incidents_changed.emit()

func wrong_answer():
	pass

func solve():
	var solved = current_issue
	if solved == null: return
	GameManager.issue_solved(solved.threat_level)
	GameManager.add_score(solved.threat_level * 100)
	has_issue = false
	current_issue = null
	patience = _cfg["patience"]
	$UI/PatienceBar.value = patience
	$UI/Exclamation.visible = false
	GameManager.incidents_changed.emit()

func escalate():
	if escalated: return
	var failed = current_issue
	if failed == null: return
	escalated = true
	GameManager.issue_failed()
	GameManager.add_danger(failed.threat_level * 8.0)
	GameManager.add_score(-failed.threat_level * 100)
	var correct_ans = failed.answers[failed.correct_index]
	GameManager.record_wrong_answer(failed.issue_name, correct_ans, failed.explanation, failed.description)
	if "unsucessful_job_hist" in GameManager:
		var already = false
		for j in GameManager.unsucessful_job_hist:
			if j.get("name","") == failed.issue_name:
				already = true; break
		if not already:
			GameManager.unsucessful_job_hist.append({
				"name": failed.issue_name,
				"description": failed.description if "description" in failed else "",
				"answer": correct_ans,
				"explanation": failed.explanation
			})
	has_issue = false
	current_issue = null
	$UI/PatienceBar.value = patience
	$UI/Exclamation.visible = false
	GameManager.incidents_changed.emit()
