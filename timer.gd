extends CanvasLayer

##Variables
var _current_timer = 0.0
var _is_running = false

## Sacar la info de los labels
@onready var _time_text = $VBoxContainer/LabelTiempo
@onready var _best_time_text = $VBoxContainer/LabelMejorTiempo
@onready var _turno_text = $VBoxContainer/LabelTurno

## INICIAR
func _ready():
	# Se Actualiza el texto para que diga quien va
	_turno_text.text = "Turno: Jugador " + str(Global.turno_actual)
	print("--- INICIANDO TURNO DEL JUGADOR ", Global.turno_actual, " ---")
	update_visuals()
	_is_running = true


##Castigo
func add_penalty(segundos:float):
	_current_timer += segundos
	print("¡CASTIGO! +", segundos, " segundos added.")
	
	#visual
	var tween = create_tween()
	tween.tween_property($VBoxContainer/LabelTiempo, "modulate", Color.RED, 0.2)
	tween.tween_property($VBoxContainer/LabelTiempo, "modulate", Color.WHITE, 0.2)

## Clausula de logica
func _process(delta):
	if _is_running:
		_current_timer += delta
		# CORRECCIÓN 1: Le pasamos el NÚMERO (_current_timer), no el texto.
		_time_text.text = time_format(_current_timer)
		
## FORMATO DEL TIEMPO
func time_format(t: float) -> String:
	var minutos = int(t / 60)
	var segundos = int(t) % 60
	var milisegundos = int((t - int(t)) * 100)
	return "%02d:%02d:%02d" % [minutos, segundos, milisegundos]
	
## --- FUNCION PARA TERMINAR LA CARRERA ---
func end_race():
	if not _is_running: return
	_is_running = false
	
	# 1. Sumar puntos a la Copa
	var indice = Global.turno_actual - 1
	Global.tiempos_totales[indice] += _current_timer
	
	# --- record neuvo
	if _current_timer < Global.record_actual:
		Global.record_actual = _current_timer
		print("¡Nuevo Récord de Nivel!")
		# Actualizamos el texto visualmente para que se vea bonito
		update_visuals() 
	# ---------------------------------------------

	print("Jugador ", Global.turno_actual, " terminó...")
	if Global.turno_actual < Global.quantity_of_players:
		# Pasa el siguiente jugador en este mismo nivel
		print("----TURNO SIGUIENTE JUGADOR-----")
		await get_tree().create_timer(3.0).timeout
		
		Global.turno_actual += 1
		get_tree().reload_current_scene()
		
	else:
		# Todos terminaron el nivel. ¿Qué hacemos ahora?
		decidir_siguiente_nivel()

func decidir_siguiente_nivel():
	var siguiente_indice = Global.indice_nivel_actual + 1
	
	# OPCIÓN a Aún quedan niveles en la lista
	if siguiente_indice < Global.playlist_niveles.size():
		print("Nivel completado vamos al siguiente...")
		await get_tree().create_timer(3.0).timeout
		
		# Preparamos variables
		Global.indice_nivel_actual = siguiente_indice
		Global.turno_actual = 1 
		Global.record_actual = 9999.0 # Reseteamos récord
		
		var siguiente_ruta = Global.playlist_niveles[siguiente_indice]
		get_tree().change_scene_to_file(siguiente_ruta)
		
	# OPCIÓN B: Ya no hay más niveles 
	else:
		print("COPA FINALIZADA")

		get_tree().change_scene_to_file("res://NIVELES Y MENU/fin.tscn")
	
	update_visuals() # para que se muestre de forma instantanea
	#Si quedan jugadores le damos
	if Global.turno_actual < Global.quantity_of_players:
		# Paso a consola para enterarme de lo que pasa
		print("¡Turno terminado! Preparando siguiente jugador...")
		
		
		# Esperp 3 segundos para celebrar/ver el tiempo
		await get_tree().create_timer(3.0).timeout
		
		# Avanzamos el turno
		Global.turno_actual += 1
		
		#Que le de el proximo tontin
		get_tree().reload_current_scene()
		
# OPCIÓN B: Ya no hay más niveles
	else:
		print("COPA FINALIZADA")
		Global.terminar_juego() 
	
func update_visuals():
	#Se revisa si el GLOBAL es igual al tiempo base
	if Global.record_actual == 9999.0:
		_best_time_text.text = "Best: --:--:--"
	else:##de otra forma es otro tiempo
		_best_time_text.text = "Best: " + time_format(Global.record_actual)
		
## Reiniciar la carrera
func restart_timer():
	_current_timer = 0.0
	_is_running = true
