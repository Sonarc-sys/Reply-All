extends VBoxContainer
class_name NotificationList

# Drag and drop your NotificationItem.tscn here in the Inspector
@export var notification_item_scene: PackedScene 

var sort_timer: float = 0.0

func _process(delta: float) -> void:
	# Only sort if we have multiple items in the list
	if get_child_count() > 1:
		sort_timer += delta
		# Re-sort every 1.0 second so UI cards don't jitter around constantly while ticking
		if sort_timer >= 1.0:
			sort_timer = 0.0
			sort_notifications_by_time()

## Call this method whenever you spawn a new employee notification!
func add_notification(employee_node: Node) -> void:
	if notification_item_scene == null:
		push_error("NotificationItem scene is not assigned in the Inspector!")
		return
		
	var item = notification_item_scene.instantiate() as NotificationItem
	add_child(item)
	item.setup(employee_node)
	
	# Immediately sort upon adding a new item
	sort_notifications_by_time()

## Sorts child NotificationItem nodes ascending by remaining patience time
func sort_notifications_by_time() -> void:
	var items: Array[Node] = get_children()
	
	if items.size() <= 1:
		return

	# Sort array: lowest remaining time (most urgent) comes FIRST (index 0)
	items.sort_custom(func(a: Node, b: Node) -> bool:
		var time_a: float = 999999.0
		var time_b: float = 999999.0
		
		if a.has_method("get_remaining_time"):
			time_a = a.get_remaining_time()
			
		if b.has_method("get_remaining_time"):
			time_b = b.get_remaining_time()
			
		return time_a < time_b
	)

	# Reorder children in the scene tree based on the sorted array
	for i in range(items.size()):
		move_child(items[i], i)
		
	# Force VBoxContainer to recalculate layout and redraw positions immediately
	queue_sort()
