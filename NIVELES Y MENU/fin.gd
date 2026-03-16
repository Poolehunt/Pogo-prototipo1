extends Control

# Referencia al contenedor donde meteremos los textos
@onready var lista_puntuaciones = $ContenedorResultados

func _ready():
	mostrar_resultados()

func mostrar_resultados():
	print("Mostrando resultados del torneo...")
	
	# --- CORRECCIÓN: Usamos la nueva variable 'tiempos_totales' ---
	for i in range(Global.tiempos_totales.size()):
		
		# Leemos el tiempo total acumulado
		var tiempo = Global.tiempos_totales[i]
		var numero_jugador = i + 1
		
		var nueva_label = Label.new()
		
		# Texto ajustado para decir "TOTAL"
		nueva_label.text = "JUGADOR " + str(numero_jugador) + " | TOTAL: " + time_format(tiempo)
		
		nueva_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lista_puntuaciones.add_child(nueva_label)
func _on_boton_volver_pressed():
	# ¡IMPORTANTE! Limpiamos los datos para el próximo torneo
	Global.resetear_datos() 
	
	# Cambiamos al menú principal (ajusta la ruta si es distinta)
	get_tree().change_scene_to_file("res://NIVELES Y MENU/menu_principal.tscn")

# --- UTILIDAD: FORMATO DE TIEMPO (Copiada para usarla aquí) ---
func time_format(t: float) -> String:
	var minutos = int(t / 60)
	var segundos = int(t) % 60
	var milisegundos = int((t - int(t)) * 100)
	return "%02d:%02d:%02d" % [minutos, segundos, milisegundos]


func _on_button_pressed() -> void:
	Global.resetear_datos() ##se resetea todo
	
	#y mandamos al menu
	get_tree().change_scene_to_file("res://NIVELES Y MENU/menu_principal.tscn")
