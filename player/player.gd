extends CharacterBody2D

class_name Player

signal healthChanged
signal playerDeath


@export var speed: int = 35
@onready var animations = $AnimationPlayer
@onready var effect = $effectAnimation
@onready var standAnimation = $StandAnimationPlayer
@onready var hurtBox = $hurtBox
@onready var hurtTimer = $hurtTimer
@onready var headSprite = $HeadSprite
@onready var feetSprite = $FeetSprite
@onready var standSprite = $StandSprite
@onready var handSprite = $HandSprite

@onready var rayCast = $RayCast2D

@onready var slash_sound = $slashSound


@export var maxHealth: int = 3
@onready var currentHealth: int = maxHealth
var isAlive: bool = true
var getHurt: bool = false

@export var knockBackDist: int = 500

@onready var weaponH = $weaponHolder


var lastAnimDirection: String = "Down"
var isAtking: bool = false

var facingDir : Vector2 = Vector2()
var facingAngleDeg : int = 0;

var currenctDirection: Vector2

var mode: String = "Normal"

func _ready():
	effect.play("RESET")
	weaponH.disable()
	#weaponH.visible = false

func handleInput():
	var moveDirection = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if Input.is_action_just_pressed("ui_left"): currenctDirection = Vector2(-1,0)
	elif Input.is_action_just_pressed("ui_right"): currenctDirection = Vector2(1,0)
	elif Input.is_action_just_pressed("ui_up"): currenctDirection = Vector2(0,-1)
	elif Input.is_action_just_pressed("ui_down"): currenctDirection = Vector2(0,1)
	velocity = moveDirection*speed


	if Input.is_action_just_pressed("atk1"):	#LM
		weaponH.primary_attack()
		slash_sound.play()


	if Input.is_action_just_pressed("atk2"):	#RM
		weaponH.secondary_attack()
		slash_sound.play()

	if Input.is_action_just_pressed("interact"): #E
		#print_debug("interact")
		try_interact()

	if Input.is_action_just_pressed("specialMove"): #SPACE
		print_debug("specialMove")
		velocity = currenctDirection*1000

	if Input.is_action_just_pressed("weapon_change_scroll"):
		print_debug("change weapon")
		weaponH.change_weapon()

func updateAnimation():
	if isAtking: return

	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
			standAnimation.stop()
	else:
		var direction: String = "Down"
		if velocity.x < 0:  direction = "Left"
		elif velocity.x > 0: direction = "Right"
		elif velocity.y < 0: direction = "Up"

		animations.play("walk"+direction)
		standAnimation.play("walk")
		#lastAnimDirection = direction

func handleCollision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		print_debug(collider.name)


func _physics_process(delta):
	if (!isAlive): return
	facingDir = get_global_mouse_position()
	var facing_angle_rad = atan2(position.y - get_global_mouse_position().y,
		position.x - get_global_mouse_position().x)
	facingAngleDeg = facing_angle_rad / PI*180
	rotation_degrees = facingAngleDeg
	# print(position)
	handleInput()
	move_and_slide()
	handleCollision()
	updateAnimation()
	if !getHurt:
		for eArea in hurtBox.get_overlapping_areas():
			if eArea.name == "hitBox":
				hurtByEnemy(eArea)


func hurtByEnemy(area):
	currentHealth -= 1
	if(currentHealth == 0):
		isAlive = false
		visible = false
		playerDeath.emit()


	healthChanged.emit(currentHealth)
	getHurt = true

	knockBack(area.get_parent().velocity)
	effect.play("HurtBlink")
	hurtTimer.start()
	await hurtTimer.timeout
	effect.play("RESET")
	getHurt = false



func _on_hurt_box_area_entered(area):
	if area.has_method("collect"):
		area.collect()


func knockBack(enemyVel: Vector2):
	var knockBackDirection = (enemyVel - velocity).normalized() * knockBackDist
	velocity = knockBackDirection
	move_and_slide()



func _on_hurt_box_area_exited(area):
	pass


func try_interact():
	'''
	rayCast.cast_to = facingDir * interactDist

	if rayCast.is_colliding():
		if rayCast.get_collider() is KinematicBody2D:
			rayCast.get_collider().take_damage(damage)
		elif rayCast.get_collider().has_method("on_interact"):
			rayCast.get_collider().on_interact(self)
	'''
	pass

func give_gold (amount):
	#gold += amount
	pass
