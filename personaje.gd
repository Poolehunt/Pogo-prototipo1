extends CharacterBody2D

##--VARIABLES DE VELOCIDAD DE MOVIMIENTO--
var _jump_check = 0#puedo saltar?
var _max_speed = 800 ##Velocidad tope
var _jump_force = -400##fuerza de salto
var _gravity = 800.0##gravedad
var _max_speed_ground = 200#velocidad tope en la tierra
var _max_jump_speed = -700
##----Pogo
var _pogo_force = -600.0 ##que tan duro salta
var _pogo_buffer = 0.07
var _pogo_buffer_counter = 0.0

var _start_position = Vector2.ZERO ##averiguar donde revive
var _shake_decay_rate = 5.0
var _shake_strength = 0.0
var shake_strength = 0

##------DASH
var _dash_speed = 900
var _can_dash = true
var _in_dash = false
var _dash_duration = 0.2
var _facing_direction = 1
##--FISICA--
var _acceleration = 300.0
var _air_resistance = 100
var _friction = 1000

##--INICIAR Y VERIFICAR PUNTO INICIAL--
func _ready() -> void:
	_start_position = global_position
	
##-----HIT AND STOP-----
##CREAMOS DOS ARGUMENTOS EN LA FUNCION
	
##------------Screen  Shake---------------

func _process(delta):
	## ---LÓGICA DEL INPUT BUFFER---
	# Esto va por su cuenta. No tiene nada que ver con la cámara.
	if Input.is_action_just_pressed("ky_J"):
		_pogo_buffer_counter = _pogo_buffer
		
	if _pogo_buffer_counter > 0:
		_pogo_buffer_counter -= delta

	## ---SCREEN SHAKE---
	
	if _shake_strength > 0:
		var real_delta = delta
		if Engine.time_scale > 0:
			real_delta = delta / Engine.time_scale
		_shake_strength = move_toward(_shake_strength, 0, _shake_decay_rate * real_delta)
		
		var camera = get_viewport().get_camera_2d()
		if camera:
			var x_noise = randf_range(-_shake_strength, _shake_strength)
			var y_noise = randf_range(-_shake_strength, _shake_strength)
			camera.offset = Vector2(x_noise, y_noise)
			
	else:
		# Solo si NO hay fuerza, reseteamos la cámara
		var camera = get_viewport().get_camera_2d()
		if camera and camera.offset != Vector2.ZERO:
			camera.offset = Vector2.ZERO

## --- FRAME FREEZE ---
func frame_freeze(time_scale, duration, shake_amount):
	##PRIMERO EL SHAKE
	# Lo activamos antes de congelar para que el jugador vea el impacto
	if shake_amount > 0:
		_shake_strength = shake_amount
	
	##AHORA CONGELAMOS
	Engine.time_scale = time_scale
	
	##ESPERAMOS
	await get_tree().create_timer(duration, true, false, true).timeout
	
	##VOLVEMOS A LA NORMALIDAD
	Engine.time_scale = 1.0

##--APLICAR FISICAS--

##limite de altura para el salto

func high_limiter():
	if velocity.y < _max_jump_speed:
		velocity.y=_max_jump_speed

##Fisicas


func _physics_process(delta):
	if _in_dash:
		move_and_slide()
		return
		
	if _can_dash==true and Input.is_action_just_pressed("ky_K"):
			start_dash()
	if not is_on_floor(): ## caer
		velocity.y += _gravity * delta
	else:
		_jump_check = 2 #si toco el suelo voy a tener mi salto recargado
		_can_dash = true
		
	if Input.is_action_just_pressed("ky_W") and _jump_check>0:
		if velocity.y <0:##si estoy volando agarro mas velocidad:
			velocity.y += _jump_force
			_jump_check -= 1
		else:##si estoy cayendo mi velocidad es la inicial del salto
			velocity.y = _jump_force
			_jump_check-= 1
	var _direction = Input.get_axis("ky_A", "ky_D") ##agarrar direccion
		
	##moverse 
	###Explicacion cuando tengo un numero distinto a 0 la velocidad en el eje x
	### Se incrementa gradualmente (O se mueve poco a poco) hacia la velocidad maxima en positivo o negativo
	###Ya que en el _direction puede ser 0, 1 o -1 y los resultados implican la direccion
	if _direction != 0:
		_facing_direction = _direction
		if is_on_floor(): ## aca compruebo si estoy en el suelo y presiono una tecla
			velocity.x = move_toward(velocity.x, _direction*_max_speed_ground, _acceleration*delta)##como si estoy en suelo tengo menos velocidad
			if abs(velocity.x) > _max_speed_ground:
				velocity.x = move_toward(velocity.x, sign(velocity.x) * _max_speed_ground, delta * _friction)
		else:##como no lo estoy voy mas rapido
			velocity.x = move_toward(velocity.x, _direction*_max_speed, _acceleration*delta)

	else:##y esto es si no presiono no
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, _friction * delta)
			if abs(velocity.x) > _max_speed_ground:
				velocity.x = move_toward(velocity.x, sign(velocity.x) * _max_speed_ground, delta * _friction)
		else:
			velocity.x = move_toward(velocity.x, 0, _air_resistance * delta)

	high_limiter()
	move_and_slide()
	
##--Pogo--

func _on_detector_area_entered(area):
	if area.is_in_group("trampa"): ## chequeo si el area pogo esta en la pua
		if _pogo_buffer_counter > 0:##si el pogo esta en la ventana valida de tiempo salto
			##HIT AND STOP SE APLICA ACA
			frame_freeze(0.01, 0.1,10)
			velocity.y = _pogo_force
			_can_dash = true
			_jump_check = 1 ##Y recargo el salto
			
			_pogo_buffer_counter = 0


func _on_detector_muerte_area_entered(area: Area2D) -> void:##pero el area donde muero es igual a la pua	
	if area.is_in_group("trampa"):
		if _pogo_buffer_counter> 0:##si el pogo esta en la ventana valida de tiempo salto
			##HIT AND STOP SE APLICA ACA
			frame_freeze(0.01, 0.1,10)
			velocity.y = _pogo_force
			_can_dash = true
			_jump_check = 1 ##Y recargo el salto
			_pogo_buffer_counter = 0

		
			
		else:##si es una trampa y no hice un pogo
			velocity.y = -400#doy un brinquito
			get_tree().call_group("timer", "add_penalty",3.0)#Sumo 3 segundos
			_can_dash = true#recargo dash
			_jump_check = 1 ##Y recargo el salto
			_pogo_buffer_counter = 0
			
			
					
##-----DASH-------

func start_dash():
	_in_dash=true
	_can_dash= false
	velocity.y = 0
	velocity.x = _facing_direction*_dash_speed
	await get_tree().create_timer(_dash_duration, true, false, true).timeout

#entonces pasa esto de aca
	_in_dash = false
	velocity.x = move_toward(velocity.x, _max_speed*_facing_direction, _friction)
	


	
