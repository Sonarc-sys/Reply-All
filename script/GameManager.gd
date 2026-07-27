extends Node

# ── Signals ───────────────────────────────────────────────────────────────────
signal incidents_changed
signal score_changed(score)
signal danger_changed(danger)
signal day_ended(data)
signal lockdown_triggered   # fired when a critical issue is failed

# ── State ─────────────────────────────────────────────────────────────────────
var score: int        = 0
var high_score: int   = 0
var danger: float     = 0.0
const DANGER_MAX: float = 100.0

var day_over: bool    = false

var shift_duration: float = 180.0
var time_left: float      = 180.0  # reset from shift_duration on play

var incidents_handled: int = 0
var incidents_failed:  int = 0
var employees: Array       = []

# ── Reflection report: tracks wrong answers ───────────────────────────────────
# Each entry: { "issue_name": str, "correct_answer": str, "explanation": str }
var wrong_answers: Array = []
var unsucessful_job_hist: Array = []

# ── Streak tracking ───────────────────────────────────────────────────────────
var current_streak: int = 0
var best_streak:    int = 0

# ── Issue pools ───────────────────────────────────────────────────────────────
var all_issues: Array         = []
var high_threat_issues: Array = []
var normal_issues: Array      = []
var critical_issues: Array    = []  # threat_level == 5, wrong answer = lockdown
var lockdown_active: bool     = false

# ── Active escalations ────────────────────────────────────────────────────────
var active_escalations: Array = []

func _ready():
	all_issues = [
		# LOW (threat 1-2)
		preload("res://resources/Issue Resources/ForgotPassword.tres"),
		preload("res://resources/Issue Resources/WeakPassword.tres"),
		preload("res://resources/Issue Resources/PublicWifi.tres"),
		preload("res://resources/Issue Resources/UnlockedScreen.tres"),
		preload("res://resources/Issue Resources/SharedPassword.tres"),
		preload("res://resources/Issue Resources/TailgatingAccess.tres"),
		# MID (threat 3)
		preload("res://resources/Issue Resources/PhishingEmail.tres"),
		preload("res://resources/Issue Resources/SocialEngineering.tres"),
		preload("res://resources/Issue Resources/PrinterData.tres"),
		preload("res://resources/Issue Resources/SuspiciousUSB.tres"),
		preload("res://resources/Issue Resources/SoftwareUpdate.tres"),
		preload("res://resources/Issue Resources/MaliciousAttachment.tres"),
		preload("res://resources/Issue Resources/RemoteDesktopExposed.tres"),
		preload("res://resources/Issue Resources/CloudMisconfiguration.tres"),
		# HIGH (threat 4)
		preload("res://resources/Issue Resources/DataLeak.tres"),
		preload("res://resources/Issue Resources/UnauthorisedAccess.tres"),
		preload("res://resources/Issue Resources/RansomwareAlert.tres"),
		preload("res://resources/Issue Resources/ZeroDayVuln.tres"),
		preload("res://resources/Issue Resources/InsiderDataTheft.tres"),
		preload("res://resources/Issue Resources/BECAttack.tres"),
		# CRITICAL (threat 5)  -  wrong answer triggers lockdown
		preload("res://resources/Issue Resources/ActiveIntrusion.tres"),
		preload("res://resources/Issue Resources/CredentialDump.tres"),
		preload("res://resources/Issue Resources/RansomwareDeployed.tres"),
		preload("res://resources/Issue Resources/SupplyChainAttack.tres"),
		preload("res://resources/Issue Resources/MFABypass.tres"),
		preload("res://resources/Issue Resources/C2Detection.tres"),
		preload("res://resources/Issue Resources/DataExfiltrationLive.tres"),
	]
	for issue in all_issues:
		if issue.threat_level == 5:
			critical_issues.append(issue)
		elif issue.threat_level >= 4:
			high_threat_issues.append(issue)
		else:
			normal_issues.append(issue)
	print("Issues loaded: ", all_issues.size(), " (critical:", critical_issues.size(), " high:", high_threat_issues.size(), " normal:", normal_issues.size(), ")")

func _process(delta):
	if day_over:
		return
	# Timer always ticks  -  popup being open never freezes the clock
	time_left -= delta
	if time_left <= 0.0:
		end_day()
		return

	# Ambient danger from open tickets + active escalations
	var open_tickets: int = 0
	for emp in employees:
		if is_instance_valid(emp) and emp.has_issue:
			open_tickets += 1
	var ambient: float = open_tickets * 0.25 * delta
	for esc in active_escalations:
		ambient += esc.escalation_rate * delta * 2.0
	if ambient > 0.0:
		danger = clamp(danger + ambient, 0.0, DANGER_MAX)
		danger_changed.emit(danger)
	if danger >= DANGER_MAX:
		end_day()

# ── Employee registration ─────────────────────────────────────────────────────
func register_employee(emp):
	if not employees.has(emp):
		employees.append(emp)

# ── Issue spawning ────────────────────────────────────────────────────────────
func spawn_issue():
	if day_over or lockdown_active:
		return
	var roll = randf()
	var pool: Array
	if roll < 0.22 and not critical_issues.is_empty():
		pool = critical_issues
	elif roll < 0.40 and not high_threat_issues.is_empty():
		pool = high_threat_issues
	else:
		pool = normal_issues
	if pool.is_empty():
		pool = all_issues
	var emp = get_available_employee()
	if emp == null:
		return
	emp.create_issue(pool.pick_random())
	incidents_changed.emit()

func get_available_employee():
	var available: Array = []
	for e in employees:
		if is_instance_valid(e) and not e.has_issue:
			available.append(e)
	if available.is_empty():
		return null
	return available.pick_random()

# ── Scoring & danger ──────────────────────────────────────────────────────────
func issue_solved(threat_level: int = 1):
	incidents_handled += 1
	current_streak += 1
	if current_streak > best_streak:
		best_streak = current_streak
	var reduction: float = threat_level * 6.0
	danger = max(0.0, danger - reduction)
	danger_changed.emit(danger)
	incidents_changed.emit()

func issue_failed():
	incidents_failed += 1
	current_streak = 0
	incidents_changed.emit()

func record_wrong_answer(issue_name: String, correct_answer: String, explanation: String):
	# Only record each unique issue once
	for entry in wrong_answers:
		if entry["issue_name"] == issue_name:
			return
	wrong_answers.append({
		"issue_name":     issue_name,
		"correct_answer": correct_answer,
		"explanation":    explanation,
	})

func add_score(amount: int):
	score += amount
	if score < 0:
		score = 0
	score_changed.emit(score)

func add_danger(amount: float):
	danger = clamp(danger + amount, 0.0, DANGER_MAX)
	danger_changed.emit(danger)
	if danger >= DANGER_MAX:
		end_day()

func add_escalation(esc):
	if esc != null and not active_escalations.has(esc):
		active_escalations.append(esc)
		add_danger(esc.severity * 6.0)

# ── Lockdown ─────────────────────────────────────────────────────────────────
func trigger_lockdown():
	if lockdown_active or day_over:
		return
	lockdown_active = true
	lockdown_triggered.emit()

func lockdown_resolved():
	lockdown_active = false

# ── End of shift ─────────────────────────────────────────────────────────────
func end_day():
	if day_over:
		return
	day_over = true
	high_score = max(high_score, score)
	day_ended.emit({
		"score":    score,
		"handled":  incidents_handled,
		"failed":   incidents_failed,
		"danger":   danger,
		"streak":   best_streak,
		"time_up":  danger < DANGER_MAX,
	})
	employees.clear()
	active_escalations.clear()
