extends Panel

signal needs_input(choices_data)

export(bool) var auto_start = false

func _ready():
	add_style_override("panel", StyleBoxEmpty.new())
	get_node("Choices").hide()
	get_node("TextBase").connect("complete", self, '_on_TextBase_complete')
	if auto_start or get_tree().get_root() == get_parent():
		start()

func start():
	get_node("TextBase").init_text()

func _on_TextBase_complete():
	get_node("Choices").show()
	var choices = {}
	for c in get_node("Choices").get_children():
		if c.selectable:
			choices[c.get_choice_id()] = c.get_data()
	emit_signal("needs_input", choices)
