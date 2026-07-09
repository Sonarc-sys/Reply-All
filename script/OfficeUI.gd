extends CanvasLayer

var current_employee
var correct_button = 0
var current_issue

func open(employee):
	current_employee = employee
	visible = true
	current_issue = employee.current_issue
	$Panel/Vbox/Question.text = current_issue.description

	# Here, we will create a big list of various button paths.
	var buttons = [$Panel/Vbox/Option1, $Panel/Vbox/Option2, $Panel/Vbox/Option3]
	
	#Here, we will track all available options [0, 1, 2] and randomize them.
	var indices = [0, 1, 2]
	indices.shuffle() 

	#Here, we will assign the text based on random indexes.
	for i in range(3):
		buttons[i].text = current_issue.answer[indices[i]]
		if indices[i] == current_issue.correct_index:
			correct_button = i

# Here, we will create button functions.
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
	visible = false

func wrong_answer():
	print("Wrong!\n\n" + current_issue.explanation)
	visible = false
