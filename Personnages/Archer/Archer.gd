extends KinematicBody2D

var base_speed = float(200)
var max_hp = 1000
var hp = max_hp

var EnemyLayer = 0b11100000000000000000
var SpellColor = Color(1.1, 0.9, 0.9)

var moving = false

var path = []
var must_click = false
var modulate_reset = 0
var velocity
var speed: float

var CC = []
var slows = []

var _aa = load("res://Personnages/Archer/aa.tscn")
var _QSpell = load("res://Personnages/Archer/Q.tscn")
var _WSpell = load("res://Personnages/Archer/W.tscn")
var _ESpell = load("res://Personnages/Archer/E.tscn")
var _RSpell = load("res://Personnages/Archer/R.tscn")

var Hp = 1000
var MaxHp = 1000
var Death = false

var Cdaa = 0
var CdaaBase = 0.4
var aaCast = 7
var aaDamage = 50
var aaShootRelease = 0
var aaShoot = false
var aaOnClick = false

var Cd2 = 0
var Cd2Base = 2.5
var QCast = 7
var QDamage = 50
var QShootRelease = 0
var QShoot = false
var QOnClick = false


var Cd4 = 0
var Cd4Base = 10
var WCD1 = 0
var WCD2 = 0
var WCast = 0
var WState = 0
var WDamage = 50
var WShootRelease = 0
var WDash = false
var WShoot = false
var WOnClick = false

var Cd5 = 0
var Cd5Base = 8
var ECast = 0.1
var ELoad = 0
var EArrow = 0
var EMaxLoad = 30
var EDamage = 75
var EShootRelease = 0
var EShoot = false
var EOnClick = false

var Cd6 = 0
var Cd6Base = 7
var RCast = 5
var RPrecision = 70
var RDamage = 125
var RShootRelease = 0
var RShoot = false
var ROnClick = false
var ROnClick2 = false

var rotationFactor = 0
var collision_info = 0
var Scriptedvelocity = Vector2()
var MovementRight = false
var MovementLeft = false
var MovementDown = false
var MovementUp = false
var ScriptedAction = ""
var DashSpeed = 0
var taille = Vector2(9,32)




func cancelMove():
	path = []
	must_click = true
	

func move(delta):
	if slows:
		speed = (slows[0]/100)*base_speed
		slows[1] -= delta
		if slows[1] <= 0:
			slows = []
	else:
		speed = base_speed
	
	look_at(get_global_mouse_position())
	if -90 < int(rotation_degrees)%360 and int(rotation_degrees)%360 < 90:
		get_node("AnimatedSprite").flip_v = false
	else:
		get_node("AnimatedSprite").flip_v = true
	
	if Input.is_mouse_button_pressed(2):
		if !must_click:
			path = get_parent().get_parent().get_simple_path(position, get_global_mouse_position(), true)
	else:
		must_click = false
	var last_point = position
	while path.size():
		var distance_between_points = last_point.distance_to(path[0])
		if speed * delta <= distance_between_points and not distance_between_points == 0:
			position = last_point.linear_interpolate(path[0], speed * delta / distance_between_points)
			return
		last_point = path[0]
		path.remove(0)
	position = last_point

func handleAnimation(delta):
	if Death:
		get_node("AnimatedSprite").animation = "dead"
		
	elif aaShoot or QShoot or WShoot or RShoot:
		get_node("AnimatedSprite").animation = "shoot"
		
	elif 0 < EShootRelease:
		get_node("AnimatedSprite").animation = "release"
		EShootRelease -= delta
		
	elif EShoot:
		get_node("AnimatedSprite").animation = "shoot"
	
	elif 0 < QShootRelease or 0 < WShootRelease or 0 < RShootRelease:
		get_node("AnimatedSprite").animation = "release"
		QShootRelease -= delta
		WShootRelease -= delta
		RShootRelease -= delta
		
	elif CC:
		if CC[0][0] == "Dash":
			get_node("AnimatedSprite").animation = "dash"
	elif path:
		get_node("AnimatedSprite").animation = "marche"
	else:
		get_node("AnimatedSprite").animation = "stand"

	while rotation_degrees > 180:
		rotation_degrees -= 360
	while rotation_degrees < -180:
		rotation_degrees += 360

func module(mod, reset):
	modulate = Color(mod)
	modulate_reset = reset

func crowdControl(CClist, delta):
	if CClist[0] == "Dash":
		module(Color(1.5, 1, 1.5), 1)
		velocity = move_and_collide(CClist[3].normalized() * delta * CClist[2])
		velocity = Vector2()
	elif CClist[0] == "SelfStun":
		pass
	elif CClist[0] == "Slide":
		velocity = move_and_collide(CClist[3].normalized() * delta * CClist[2] * CClist[1])
		velocity = Vector2()

func die():
	pass

func inputs(delta):
	aa(Input.is_action_pressed("aa"), delta*60)
	Spell2(Input.is_action_pressed("1"), delta*60)
	Spell4(Input.is_action_pressed("2"), delta*60)
	Spell5(Input.is_action_pressed("3"), delta*60)
	Spell6(Input.is_action_pressed("4"), delta*60)
	
func aa(Condition, delta):
	if Condition:
		if not aaOnClick and not Cdaa > 0:
			if aaCast > 0:
				aaCast -= delta
				aaShoot = true
				slows = [80.0, 0.1]
			else:
				var aa = _aa.instance()
				get_parent().add_child(aa)
				aa.Launch(Vector2(position.x, position.y), aaDamage)
				aa.NodeAnimation.self_modulate = SpellColor
				aaOnClick = true
				aaShoot = false
				aaShootRelease = 0.08
				Cdaa = CdaaBase
				cancelMove()
	else:
		aaCast = 12
		aaShoot = false
		aaOnClick = false

func Spell2(Condition, delta):
	if Condition:
		if not QOnClick and not Cd2 > 0:
			if QCast > 0:
				QCast -= delta
				QShoot = true
				slows = [70.0, 0.1]
			else:
				var QSpell = _QSpell.instance()
				get_parent().add_child(QSpell)
				QSpell.Launch(Vector2(position.x, position.y), QDamage)
				QSpell.NodeAnimation.self_modulate = SpellColor
				QOnClick = true
				QShoot = false
				QShootRelease = 0.08
				Cd2 = Cd2Base
				cancelMove()
	else:
		QCast = 36
		QShoot = false
		QOnClick = false

func Spell4(Condition, delta):
	if Condition:
		if not WOnClick and not Cd4 > 0:
			if WState <= 0:
				if WCast > 0:
					WCast -= delta
					WShoot = true
					speed /= 3
				else:
					var WSpell = _WSpell.instance()
					get_parent().add_child(WSpell)
					WSpell.Launch(Vector2(position.x, position.y), QDamage)
					WSpell.NodeAnimation.self_modulate = SpellColor
					WOnClick = true
					WShoot = false
					WShootRelease = 0.08
					Cd4 = Cd4Base
					WState = -2
					cancelMove()
			else:
				var Scriptedvelocity = Vector2()
				DashSpeed = 10
				CC.append(["Dash",10.0, 10, Scriptedvelocity])
				WState = -1
				Cd4 = WCD2
	else:
		WCast = 2
		WShoot = false
		WOnClick = false

func Spell5(Condition, delta):
	if Condition:
		if not EOnClick and not Cd5 > 0:
			ELoad = 1
			EArrow = 1
			EOnClick = true
			EShoot = true
		else:
			if not Cd5 > 0 and EArrow:
				slows = [40.0, 0.1]
				if ELoad and not EArrow > 3:
					if ELoad >= EMaxLoad and not EArrow > 2:
						EArrow += 1
						ELoad = 1
					else:
						if not EArrow > 2 or not ELoad >= EMaxLoad:
							ELoad += delta
						else:
							ELoad = EMaxLoad
							EArrow = 3
				
	else:
		if ELoad:
			if 0 > ECast:
				var ESpell = _ESpell.instance()
				get_parent().add_child(ESpell)
				ESpell.Launch(Vector2(position.x, position.y), rand_range(ELoad / 2, -ELoad / 2), EDamage)
				ESpell.NodeAnimation.self_modulate = SpellColor
				EArrow -= 1
				Cd5 = Cd5Base
				ECast = 0.15
				EShootRelease = 0.08
				if not EArrow:
					ELoad = 0
					EShoot = false
					cancelMove()
		EOnClick = false
	
func Spell6(Condition, delta):
	if Condition:
		if Cd6 <= 0:
			if not ROnClick or ROnClick2:
				RShoot = true
				ROnClick2 = true
				slows = [20.0, 0.1]
				RPrecision -= delta*10
				if RPrecision <=0:
					RPrecision = 0
		ROnClick = true
	else:
		ROnClick = false
		if ROnClick2:
			var RSpell = _RSpell.instance()
			get_parent().add_child(RSpell)
			RSpell.Launch(Vector2(position.x, position.y), rand_range(RPrecision / 2, -RPrecision / 2), RDamage)
			ROnClick2 = false
			RPrecision = 70
			RShootRelease = 0.08
			Cd6 = Cd6Base
		else:
			RCast = 0.03
			RShoot = false

func cooldown(delta):
	if Cdaa > 0:
		Cdaa -= delta
	if Cd2 > 0:
		Cd2 -= delta
	if Cd4 > 0:
		Cd4 -= delta
	if Cd5 > 0:
		Cd5 -= delta
	if ECast > 0:
		ECast -= delta
	if Cd6 > 0:
		Cd6 -= delta
	if modulate_reset > 0:
		modulate_reset -= delta
	elif -1000 != modulate_reset and modulate_reset < 0:
		modulate = Color(1, 1, 1)
		modulate_reset = -1

func _process(delta):
	speed = base_speed
	cooldown(delta)
	if hp <= 0:
		die()
	else:
		var bop = true
		for i in CC:
			if i[1] > 0:
				bop = false
				crowdControl(i, delta)
				i[1] -= delta
		if bop:
			CC = []
			move(delta)
	inputs(delta)
	handleAnimation(delta)


func _ready():
	pass
