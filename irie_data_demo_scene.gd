class_name IrieDataDemoScene
extends Node3D

@export var data_set:IrieDataDemoDataSet

func _ready() -> void:
	prints('IrieDataDemoScene ready')
	prints('shapes:', data_set._shapes.get_row_count())
	prints('materials:', data_set._materials.get_row_count())
	prints('objects:', data_set._objects.get_row_count())

	var obstacles = data_set.get_obstacles()
	prints('objects', obstacles)
