@tool
class_name IrieDataDemoDataSet
extends IrieDataSet

enum ShapeType {
	sphere,
	box,
	cone
}

class ShapeData:
	var name:String
	var type:ShapeType = ShapeType.box
	var size:Vector3 = Vector3(1, 2, 3)

class MaterialData:
	var name:String
	var color:Color

class ObstacleData:
	var name:String
	var shape:ShapeData
	var material:MaterialData

var _shapes = table('shapes', ShapeData, {
	'name': schema_key()
})

var _materials = table('materials', MaterialData, {
	'name': schema_key()
})

var _obstacles = table('objects', ObstacleData, {
	'name': schema_key(),
	'shape': schema_relation(_shapes), 
	'material': schema_relation(_materials)
})

func get_obstacles() -> Array[ObstacleData]:
	return _obstacles.get_all_rows() as Array[ObstacleData]
