extends Control

var current_employee
var correct_button = 0
var current_issue

func open(employee):
	current_employee = employee
	visible = true
	current_issue = employee.current_issue
	$Panel/Vbox/Question.text = current_issue.description

	var answers = current_issue.answers.duplicate()
	var correct_answer = answers[current_issue.correct_index]

	answers.shuffle()

	$Panel/Vbox/Option1.text = answers[0]
	$Panel/Vbox/Option2.text = answers[1]
	$Panel/Vbox/Option3.text = answers[2]
	
	correct_button = answers.find(correct_answer)

#Button Functions
func _on_option_1_pressed():
	check_answer(0)

func _on_option_2_pressed():
	check_answer(1)

func _on_option_3_pressed():
	check_answer(2)
	
func check_answer(button):
	if button == correct_button:
		correct_answer()
	else:
		wrong_answer()
		
func correct_answer():
	print("Correct!")
	current_employee.solve()
	visible=false

func wrong_answer():
	print("Wrong!\n\n"
		+ current_issue.explanation)
	visible=false
