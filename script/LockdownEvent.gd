extends CanvasLayer

signal lockdown_cleared
signal lockdown_failed

const LOCKDOWN_TIME = 45.0

var time_remaining: float = LOCKDOWN_TIME
var npcs_to_clear: Array = []
var npcs_cleared_set: Array = []
var active: bool = false

@onready var overlay     = $Overlay
@onready var timer_label = $Panel/VBox/TimerLabel
@onready var status_label= $Panel/VBox/StatusLabel
@onready var progress_bar= $Panel/VBox/ProgressBar
@onready var header_label= $Panel/VBox/HeaderLabel

func start(all_employees: Array):
	active = true
	npcs_to_clear   = all_employees.filter(func(e): return is_instance_valid(e))
	npcs_cleared_set = []
	time_remaining  = LOCKDOWN_TIME
	visible = true

	if has_node("/root/AudioManager"):
		var music = load("res://audio/lockdown_music.wav")
		if music: get_node("/root/AudioManager").play_music(music, true, -6.0)

	progress_bar.max_value = npcs_to_clear.size()
	progress_bar.value     = 0
	header_label.text      = "SECURITY BREACH DETECTED"
	_update_status()

	# Show large red exclamation on every NPC
	for emp in npcs_to_clear:
		if is_instance_valid(emp):
			emp.show_lockdown_alert()

	# Tell player to reset their cleared set
	var player = get_tree().get_root().find_child("Player", true, false)
	if player and player.has_method("reset_lockdown_cleared"):
		player.reset_lockdown_cleared()

	# Pulse red overlay
	var tw = create_tween().set_loops(6)
	tw.tween_property(overlay, "color", Color(0.85, 0.0, 0.0, 0.20), 0.25)
	tw.tween_property(overlay, "color", Color(0.85, 0.0, 0.0, 0.04), 0.25)

func _process(delta):
	if not active:
		return
	time_remaining -= delta
	timer_label.text = "TIME REMAINING: %.1f" % max(0.0, time_remaining)
	if time_remaining < 10.0:
		timer_label.modulate = Color(0.95, 0.15, 0.15)
	elif time_remaining < 20.0:
		timer_label.modulate = Color(1.0, 0.6, 0.1)
	else:
		timer_label.modulate = Color(1.0, 0.82, 0.2)
	if time_remaining <= 0.0:
		_fail()

func notify_npc_cleared(emp):
	if not active:
		return
	# Guard: only count each NPC once
	if npcs_cleared_set.has(emp):
		return
	if not npcs_to_clear.has(emp):
		return
	npcs_cleared_set.append(emp)
	progress_bar.value = npcs_cleared_set.size()

	if is_instance_valid(emp):
		emp.hide_lockdown_alert()

	if has_node("/root/AudioManager"):
		var sfx = load("res://audio/sfx_correct.wav")
		if sfx: get_node("/root/AudioManager").play_sfx(sfx, -2.0, 1.3)

	_update_status()

	if npcs_cleared_set.size() >= npcs_to_clear.size():
		_success()

func _update_status():
	var remaining = npcs_to_clear.size() - npcs_cleared_set.size()
	status_label.text = "Press E on each employee to clear their station.\n%d stations remaining." % remaining

func _success():
	active = false
	header_label.text  = "BREACH CONTAINED"
	status_label.text  = "All stations cleared. Network secured."
	timer_label.modulate = Color(0.2, 0.9, 0.3)
	GameManager.add_score(500)

	# Clear ALL exclamation marks
	for emp in npcs_to_clear:
		if is_instance_valid(emp):
			emp.hide_lockdown_alert()

	if has_node("/root/AudioManager"):
		var music = load("res://audio/menu_music.wav")
		if music: get_node("/root/AudioManager").play_music(music, true, -10.0)

	var tw = create_tween()
	tw.tween_interval(2.2)
	tw.tween_callback(func():
		visible = false
		lockdown_cleared.emit()
	)

func _fail():
	active = false

	# Clear exclamation marks even on failure
	for emp in npcs_to_clear:
		if is_instance_valid(emp):
			emp.hide_lockdown_alert()

	visible = false
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").stop_music()
	GameManager.danger = 100.0
	GameManager.danger_changed.emit(100.0)
	lockdown_failed.emit()
