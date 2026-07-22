extends Control

@onready var job_list: ItemList = $SplitView/JobList
@onready var details_label: Label = $DetailsPanel/Label
@onready var explanation_label: Label = $DetailsPanel/ExplanationLabel
@onready var back_button: Button = $BackButton

var failed_jobs: Array = []

func _ready() -> void:
	if not job_list or not details_label or not explanation_label or not back_button:
		printerr("Scoreboard Error: Missing node -> JobList: ", job_list, " | Details: ", details_label, " | Exp: ", explanation_label, " | Back: ", back_button)
		return

	job_list.item_selected.connect(_on_job_selected)
	back_button.pressed.connect(_on_back_button_pressed)
	
	load_failed_jobs()

func load_failed_jobs() -> void:
	job_list.clear()
	failed_jobs.clear()
	
	if GameManager and "unsucessful_job_hist" in GameManager:
		failed_jobs = GameManager.unsucessful_job_hist
		
	for job in failed_jobs:
		var job_name = job.get("name", "Unknown Issue")
		job_list.add_item(job_name)
		
	if failed_jobs.is_empty():
		job_list.add_item("No failed tasks recorded.")
		job_list.set_item_disabled(0, true)
		details_label.text = "Select a task to review its details."
		explanation_label.text = ""
	else:
		job_list.select(0)
		_on_job_selected(0)

func _on_job_selected(index: int) -> void:
	if index < 0 or index >= failed_jobs.size():
		return
		
	var job = failed_jobs[index]
	var desc = job.get("description", "No description available.")
	var ans = job.get("answer", "N/A")
	var exp = job.get("explanation", "No explanation provided.")
	
	details_label.text = "Description:\n%s\n\nYour Answer:\n%s" % [desc, ans]
	explanation_label.text = "Explanation:\n%s" % [exp]

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/GameOver.tscn")
