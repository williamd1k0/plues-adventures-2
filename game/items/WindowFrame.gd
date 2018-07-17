extends ColorFrame

onready var move_rect = get_node("MoveRect").get_rect()
var dragging = false
var last_pos = Vector2()

func _ready():
	get_node("Title").set_text(
		"GodotOS-{major}.{minor}.{patch}-{status}:~/Games/plue2".format(OS.get_engine_version())
	)
	set_process_input(true)

func _input(event):
	if event.type == InputEvent.MOUSE_BUTTON:
		dragging = event.pressed and move_rect.has_point(get_local_mouse_pos())
		if dragging:
			last_pos = get_global_mouse_pos()
	elif dragging and event.type == InputEvent.MOUSE_MOTION:
		OS.set_window_position(OS.get_window_position() + get_global_mouse_pos() - last_pos)

func _on_Quit_pressed():
	get_tree().quit()

func _on_Minimize_pressed():
	OS.set_window_minimized(true)
	get_node("Menus/Minimize").release_focus()
