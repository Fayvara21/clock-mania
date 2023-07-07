extends Node2D

var screencenter;

var time_begin
var time_delay
var frames
var prevtime

var clock
var notes
var clockspeed
var colors

var measure
var measurestep
var measurestepangle

var blue
var bluespeed
var red
var redspeed
var yellow
var yellowspeed

var isspawned
var notelist = []
var handguide = []
var guidelist = []

var x = 0;

func _ready():
	
	time_begin = Time.get_ticks_usec()
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()

	screencenter = get_viewport_rect().size / 2.0;
	
	measurestep = 8
	measure = setmeasure(measurestep)
	
	selftimer()
	
	frames = 0
	prevtime = 0
	notes = $notes
	clock = $clock
	blue = $clock/HandBlue
	red = $clock/HandRed
	yellow = $clock/HandYellow
	colors = [blue, red, yellow]

	for i in colors:
		spawnguide(i)
		
	syncsong(60, 0,0)
	
func getangle(color):
	var angle = Vector2(cos(color.rotation),sin(color.rotation))
	return angle
	
func setangle(color, angle):
	if typeof(angle) == 5:
		color.rotation = atan2(angle.x, angle.y)
	else:
		color.rotation = angle
	
func resetangle(color):
	if color.rotation >= 2*PI:
		color.rotation -= 2*PI

func setmeasure(divider):
	var turn = []
	measurestepangle = (2*PI)/divider
	for i in range(divider):
		turn.append(((2*PI)/divider)*x)
	return turn
	
func spawnnote(notecolor, noteangle):
	var newnote
	var note
	var noteoffset
	match notecolor:
		blue:
			note = $notes/Blue
			noteoffset = Vector2(0,40)
		red:
			note = $notes/Red
			noteoffset = Vector2(0,50)
		yellow:
			note = $notes/Yellow
			noteoffset = Vector2(0,60)
	newnote = note.duplicate()
	newnote.position = Vector2.ZERO
	newnote.offset = -noteoffset
	newnote.rotation = noteangle
	newnote.scale = Vector2(5,5)
	note.add_child(newnote)
	return newnote
		
func setglobalposition(pos):
	clock.position = pos
	notes.position = clock.position
	$guide.position = clock.position

var timesinccheck

func syncsong(bpm, offset, time):
	var bps = bpm/60.0
	var rpb = measurestepangle*bps
	clockspeed = bps
	print(clockspeed)
	var elapsedtime

func selftimer():
	var selftimer = Timer.new()
	selftimer.wait_time = 1.0  # Interval of 1 second
	selftimer.one_shot = false  # Repeats the timer indefinitely
	selftimer.name = "Timer"
	selftimer.connect("timeout", self.timeout)
	add_child(selftimer)
	selftimer.start()

func timeout():
	for child in self.get_children():
		if child is Timer:
			child.queue_free()
	#spawnnote(red, red.rotation)
	selftimer()

func spawnguide(color):
	var guide	
	guide = color.duplicate()
	guide.position = Vector2.ZERO
	guide.visible = true
	guide.rotation = 0
	$guide.add_child(guide)
	guidelist.append([])
	match color:
		blue:
			handguide.append($guide/HandBlue)
		red:
			handguide.append($guide/HandRed)
		yellow:
			handguide.append($guide/HandYellow)
func guideprocess(delayed):
	
	for i in range(len(colors)):
		guidelist[i].append(colors[i].rotation)
		if delayed:
			handguide[i].rotation = guidelist[i][0]
			guidelist[i].pop_front()

var guidedelaycheck

func _physics_process(delta):
	
	var time = (Time.get_ticks_usec() - time_begin) / 1000000.0
	time -= time_delay
	time = max(0, time)
	
	frames += 1
	#delta = time - prevtime
	prevtime = time

	for color in colors:
		resetangle(color)
	
	setglobalposition(screencenter)
	
	bluespeed = 2 
	yellowspeed = 1
	redspeed = 0.5
	
	await get_tree().create_timer(1).timeout
	
	
	x += delta*PI*clockspeed
	
	red.rotation = sin(x)*redspeed*PI 
	blue.rotation += bluespeed*delta*PI* clockspeed
	yellow.rotation += yellowspeed*delta*PI* clockspeed
	
	
	guideprocess(guidedelaycheck)
	await get_tree().create_timer(2).timeout
	guidedelaycheck = true
	
	$Player.play()
	
#if Input.is_action_pressed("blue"):
		
		
	

	
	

	
	
	
	
	
