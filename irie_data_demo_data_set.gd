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
	var type:ShapeType
	var size:Vector3

class MaterialData:
	var name:String
	var color:Color

class ObstacleData:
	var name:String
	var shape:ShapeData
	var material:MaterialData

var _shapes = table('shapes', ShapeData)
var _materials = table('materials', MaterialData)
var _obstacles = table('objects', ObstacleData, {
	'shape': { 'relation': _shapes }, 
	'material': { 'relation': _materials }
})

func get_obstacles() -> Array[ObstacleData]:
	return _obstacles.get_all_rows() as Array[ObstacleData]
