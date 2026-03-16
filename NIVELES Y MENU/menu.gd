extends Control

# Esta función NO la uses para esto, bórrala o déjala vacía con pass
func _process(delta: float) -> void:
	pass

# AQUÍ es donde va la magia (Solo ocurre cuando haces Clic)
func _on_button_pressed() -> void:
	# 1. Leemos el valor
	var numero_elegido = int($VBoxContainer/SpinBox.value)
	
	# 2. Guardamos en Global
	# Asegúrate de que en global.gd la variable se llame IGUAL (Quantity_of_players)
	Global.quantity_of_players = numero_elegido 
	Global.resetear_datos()
	
	print("Juego configurado para ", numero_elegido, " jugadores.")
	
	# 3. Cambiamos de escena
	get_tree().change_scene_to_file("res://NIVELES Y MENU/nivel1.tscn")
