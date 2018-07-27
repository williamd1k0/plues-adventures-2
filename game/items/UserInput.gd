extends LineEdit

signal command(cmd)
signal text_type

export(StringArray) var valid_inputs
export(bool) var auto_focus = false
export(bool) var check_bad_words = true
const BAD_WORDS_FOLDER = 'res://assets/bad-words'
var global_inputs = ['quit', 'exit', '^z', 'save']
var history = []
var h_index = 0
var text_cache = ''
var regex = RegEx.new()

func _ready():
	if check_bad_words:
		load_regex()
	lock()
	if valid_inputs == null:
		valid_inputs = []
	if get_tree().get_root() == get_parent() or auto_focus:
		wait_command(valid_inputs)

func lock():
	release_focus()
	set_ignore_mouse(true)
	cursor_set_blink_enabled(false)
	set_editable(false)
	clear()

func wait_command(commands=null):
	clear()
	if commands != null:
		valid_inputs = commands
	set_ignore_mouse(false)
	grab_focus()
	cursor_set_blink_enabled(true)
	set_editable(true)
	if valid_inputs.size() <= 1:
		set_placeholder(tr("INPUT_CONTINUE"))

func global_command(cmd):
	var cmd_list = cmd.split(' ')
	if cmd in ['quit', 'exit']:
		set_placeholder(tr('INPUT_EXIT'))
	elif cmd == '^z':
		get_tree().quit()
	elif cmd_list[0] == 'save':
		get('current_panel')
		if get_parent().get('current_panel'):
			SaveData.add_save_point(get_parent().current_panel)
			type_info(tr('INPUT_SAVED'))
			yield(self, 'text_type')
			wait_command()
	else:
		history.append(cmd)
		set_placeholder(tr("INPUT_UNKNOWN"))

func _input_event(event):
	if not is_editable():
		return
	if event.is_action_pressed("ctrlZ"):
		call_deferred('set_text', get_text()+'^Z')
		call_deferred('set_cursor_pos', 2)
	elif event.is_action_pressed("console_return"):
		process_input()
	elif event.is_action_pressed("ui_up"):
		if history.size() > abs(h_index):
			h_index -= 1
			set_text(history[h_index])
			call_deferred('set_cursor_pos', get_text().length())
	elif event.is_action_pressed("ui_down"):
		if history.size() >= abs(h_index) and h_index < -1:
			h_index += 1
			set_text(history[h_index])
			call_deferred('set_cursor_pos', get_text().length())


func process_input():
	var text = get_text().strip_edges()
	if check_bad_words and contains_bad_words(text):
		type_info(tr('INPUT_BAD'))
		yield(self, 'text_type')
		wait_command()
	elif global_inputs.size() > 0 and text.to_lower().split(' ')[0] in global_inputs:
		global_command(text.to_lower())
	elif valid_inputs.size() == 0 or text in valid_inputs:
		while Input.is_action_pressed("console_return"):
			get_node("Wait").set_wait_time(0.1)
			get_node("Wait").start()
			yield(get_node("Wait"), 'timeout')
		emit_signal("command", text)
		set_placeholder("")
		history.append(text)
		lock()
	elif text == "":
		set_placeholder(tr("INPUT_TYPE"))
	else:
		history.append(text)
		set_placeholder(tr("INPUT_UNKNOWN"))
	h_index = 0
	clear()

func type_info(info, time=4):
	lock()
	text_cache = info
	get_node("Tween").interpolate_method(
		self, '_text_type',
		0, text_cache.length(),
		2.0, Tween.TRANS_SINE,
		Tween.EASE_IN
	)
	get_node("Tween").start()
	yield(get_node("Tween"), 'tween_complete')
	get_node("Wait").set_wait_time(time)
	get_node("Wait").start()
	yield(get_node("Wait"), 'timeout')
	set_placeholder("")
	emit_signal("text_type")

func _text_type(index):
	set_placeholder(text_cache.substr(0, int(index)))

func load_regex():
	var dir = Directory.new()
	dir.open(BAD_WORDS_FOLDER)
	dir.list_dir_begin()
	var file
	var files = []
	while file != '':
		file = dir.get_next()
		if file in ['', '.', '..']:
			continue
		var f = File.new()
		f.open(BAD_WORDS_FOLDER.plus_file(file), File.READ)
		files.append(array_join(f.get_as_text().split('\n'), '|'))
		f.close()
	regex.compile(array_join(files, '|'))

func array_join(array, sep):
	var rs = ""
	for s in array:
		rs += s+sep
	rs.erase(rs.length()-1, 1)
	return rs

func contains_bad_words(text):
	return regex.find(text) >= 0
