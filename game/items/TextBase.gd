extends Label

signal complete
signal type_done

export(bool) var auto_start = false
export(float) var char_time = 0.5
export(bool) var blink = false
export(bool) var can_skip = true
onready var tween = get_node("Tween")

func _ready():
	set_percent_visible(0)
	if auto_start and not get_parent().is_in_group('main-text'):
		init_text()

func _input(event):
	if event.is_action_released("console_return"):
		tween.stop_all()
		set_percent_visible(1)
		tween.emit_signal("tween_complete")

func init_text():
	type_text()
	set_process_input(can_skip)
	yield(tween, 'tween_complete')
	set_process_input(false)
	emit_signal("type_done")
	if blink:
		get_node("Blink").play("blink")
	for child in get_children():
		if child.is_in_group('main-text'):
			child.init_text()
			yield(child, "complete")
	emit_signal("complete")

func type_text():
	tween.interpolate_method(
		self, "set_percent_visible",
		0.0, 1.0,
		max(get_text().length(), 1)*(char_time/10),
		Tween.TRANS_SINE,
		Tween.EASE_IN
	)
	tween.start()
