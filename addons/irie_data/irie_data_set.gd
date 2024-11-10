@tool
class_name IrieDataSet
extends Resource

enum PropertyType {
    UNKNOWN,
    BOOL,
    COLOR,
    ENUM,
    FLOAT,
    STRING
}

class PropertyResource:
    extends Resource

    @export var prop_name:String
    @export var prop_type:PropertyType

    func delete_row(row_index:int) -> void:
        pass

    func is_for_prop(prop:Dictionary) -> bool:
        return false

    func remove_unused_rows(unused_row_indexes:PackedInt32Array) -> void:
        pass

    func delete_all_rows() -> void:
        pass


class PropertyResourceBool:
    extends PropertyResource

    # TODO: pack multiple rows into a single byte?

    static func for_prop(prop:Dictionary) -> PropertyResourceBool:
        var resource:PropertyResourceBool = PropertyResourceBool.new()
        resource.prop_name = prop['name']
        resource.prop_type = PropertyType.BOOL
        return resource

    @export var data:PackedByteArray = [] 

    func get_value(row_index:int) -> bool:
        return data[row_index]

    func set_value(row_index:int, new_value:bool) -> void:
        data[row_index] = new_value

    func remove_unused_rows(unused_row_indexes:PackedInt32Array) -> void:
        var new_data:PackedByteArray = []
        new_data.resize(data.size() - unused_row_indexes.size())
        var dst_index:int = 0
        var next_unused_row_indexes_index:int = 0;
        var next_unused_row_index:int = unused_row_indexes[next_unused_row_indexes_index]
        for src_index:int in data.size():
            if src_index == next_unused_row_index:
                next_unused_row_indexes_index += 1
                next_unused_row_index = unused_row_indexes[next_unused_row_indexes_index]
            else:
                new_data[dst_index] = data[src_index]
                dst_index += 1
        data = new_data       

    func delete_all_rows() -> void:
        data.clear()

    func is_for_prop(prop:Dictionary) -> bool:
        return prop_name == prop['name'] && prop['type'] == TYPE_BOOL


class PropertyResourceColor:
    extends PropertyResource

    static func for_prop(prop:Dictionary) -> PropertyResourceColor:
        var resource:PropertyResourceColor = PropertyResourceColor.new()
        resource.prop_name = prop['name']
        resource.prop_type = PropertyType.COLOR
        return resource

    @export var data:PackedColorArray = [] 
    
    func get_value(row_index:int) -> Color:
        return data[row_index]

    func set_value(row_index:int, new_value:Color) -> void:
        data[row_index] = new_value

    func remove_unused_rows(unused_row_indexes:PackedInt32Array) -> void:
        var new_data:PackedColorArray = []
        new_data.resize(data.size() - unused_row_indexes.size())
        var dst_index:int = 0
        var next_unused_row_indexes_index:int = 0;
        var next_unused_row_index:int = unused_row_indexes[next_unused_row_indexes_index]
        for src_index:int in data.size():
            if src_index == next_unused_row_index:
                next_unused_row_indexes_index += 1
                next_unused_row_index = unused_row_indexes[next_unused_row_indexes_index]
            else:
                new_data[dst_index] = data[src_index]
                dst_index += 1  
        data = new_data       

    func delete_all_rows() -> void:
        data.clear()

    func is_for_prop(prop:Dictionary) -> bool:
        return prop_name == prop['name'] && prop['type'] == TYPE_COLOR


class PropertyResourceEnum:
    extends PropertyResource

    @export var data:PackedByteArray = []
    @export var enum_hint:String = ''

    static func is_enum_prop(prop:Dictionary):
        return false

    static func for_prop(prop:Dictionary) -> PropertyResourceEnum:
        var resource:PropertyResourceEnum = PropertyResourceEnum.new()
        resource.prop_name = prop['name']
        resource.prop_type = PropertyType.ENUM
        resource.enum_hint = prop['hint']
        return resource

    func get_value(row_index:int) -> float:
        return data[row_index]

    func set_value(row_index:int, new_value:float) -> void:
        data[row_index] = new_value

    func remove_unused_rows(unused_row_indexes:PackedInt32Array) -> void:
        var new_data:PackedByteArray = []
        new_data.resize(data.size() - unused_row_indexes.size())
        var dst_index:int = 0
        var next_unused_row_indexes_index:int = 0;
        var next_unused_row_index:int = unused_row_indexes[next_unused_row_indexes_index]
        for src_index:int in data.size():
            if src_index == next_unused_row_index:
                next_unused_row_indexes_index += 1
                next_unused_row_index = unused_row_indexes[next_unused_row_indexes_index]
            else:
                new_data[dst_index] = data[src_index]
                dst_index += 1
        data = new_data       

    func delete_all_rows() -> void:
        data.clear()

    func is_for_prop(prop:Dictionary) -> bool:
        return prop_name == prop['name'] && prop['type'] == TYPE_INT && prop['hint'] == enum_hint


class PropertyResourceFloat:
    extends PropertyResource

    static func for_prop(prop:Dictionary) -> PropertyResourceFloat:
        var resource:PropertyResourceFloat = PropertyResourceFloat.new()
        resource.prop_name = prop['name']
        resource.prop_type = PropertyType.FLOAT
        return resource

    @export var data:PackedFloat64Array = []

    func _init() -> void:
        prop_type = PropertyType.FLOAT

    func get_value(row_index:int) -> float:
        return data[row_index]

    func set_value(row_index:int, new_value:float) -> void:
        data[row_index] = new_value

    func remove_unused_rows(unused_row_indexes:PackedInt32Array) -> void:
        var new_data:PackedFloat64Array = []
        new_data.resize(data.size() - unused_row_indexes.size())
        var dst_index:int = 0
        var next_unused_row_indexes_index:int = 0;
        var next_unused_row_index:int = unused_row_indexes[next_unused_row_indexes_index]
        for src_index:int in data.size():
            if src_index == next_unused_row_index:
                next_unused_row_indexes_index += 1
                next_unused_row_index = unused_row_indexes[next_unused_row_indexes_index]
            else:
                new_data[dst_index] = data[src_index]
                dst_index += 1
        data = new_data       

    func delete_all_rows() -> void:
        data.clear()

    func is_for_prop(prop:Dictionary) -> bool:
        return prop_name == prop['name'] && prop['type'] == TYPE_FLOAT


class PropertyResourceString:
    extends PropertyResource

    static func for_prop(prop:Dictionary) -> PropertyResourceString:
        var resource:PropertyResourceString = PropertyResourceString.new()
        resource.prop_name = prop['name']
        resource.prop_type = PropertyType.STRING
        return resource

    @export var data:PackedStringArray = []

    func get_value(row_index:int) -> String:
        return data[row_index]

    func set_value(row_index:int, new_value:String) -> void:
        data[row_index] = new_value

    func delete_row(row_index:int) -> void:
        data[row_index] = ''

    func remove_unused_rows(unused_row_indexes:PackedInt32Array) -> void:
        var new_data:PackedStringArray = []
        new_data.resize(data.size() - unused_row_indexes.size())
        var dst_index:int = 0
        var next_unused_row_index:int = unused_row_indexes[0]
        var unused_row_indexes_index:int = 1;
        for src_index:int in data.size():
            if src_index == next_unused_row_index:
                next_unused_row_index = unused_row_indexes[unused_row_indexes_index]
                unused_row_indexes_index += 1
            else:
                new_data[dst_index] = data[src_index]
                dst_index += 1
        data = new_data       

    func delete_all_rows() -> void:
        data.clear()


class TableResource:
    extends Resource

    @export var table_name:String
    @export var property_resources:Dictionary = {}
    @export var row_count:int = 0

class IrieDataTable:

    var name:String:
        get():
            return _table_resource.table_name

    var _data_set:IrieDataSet
    var _table_resource:TableResource
    var _schema_class:Variant
    var _options:Dictionary
    var _unused_row_indexes:PackedInt32Array = []
    
    func _init(data_set:IrieDataSet, name:String, schema_class:Variant, options:Dictionary):
        prints('IrieDataTable', name, schema_class, options)
        _data_set = data_set
        _schema_class = schema_class
        _options = options
        _table_resource = _init_table_resource(name)
        _init_property_resources()
        _verify_relations()

    func _init_table_resource(name:String) -> TableResource:
        var table_resource:TableResource = _data_set.tables.get(name)
        if not table_resource:
            table_resource = TableResource.new()
            table_resource.table_name = name
            _data_set.tables[name] = table_resource
        return table_resource

    func _init_property_resources():

        if _schema_class is not GDScript:
            push_error('schema_class must be a GDScript defined class')
            return

        for prop in _schema_class.get_script_property_list():
            var prop_name:String = prop['name']
            var prop_usage:PropertyUsageFlags = prop['usage']
            if prop_usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
                var resource = _table_resource.property_resources.get(prop_name)
                if not resource:
                    prints('  add to property map', prop)
                    resource = _create_resource_for_property(prop)
                    _table_resource.property_resources[prop_name] = resource
                else:
                    prints('  found in property map', prop)
                    if not resource.is_for_prop(prop):
                        push_error('property type mismatch')


    func _create_resource_for_property(prop:Dictionary) -> PropertyResource:
        var prop_type:Variant.Type = prop['type']
        var resource:PropertyResource = null
        match prop_type:
            TYPE_BOOL:
                resource = PropertyResourceBool.for_prop(prop)
            TYPE_COLOR:
                resource = PropertyResourceColor.for_prop(prop)
            TYPE_FLOAT:
                resource = PropertyResourceFloat.for_prop(prop)
            TYPE_INT:
                if PropertyResourceEnum.is_enum_prop(prop):
                    resource = PropertyResourceEnum.for_prop(prop)
            _:
                push_error('unsupported property type')
        return resource


    func _verify_relations():
        pass

    func get_row_count() -> int:
        return _table_resource.row_count

    func get_all_rows() -> Array[Object]:
        var result:Array[Object] = []
        result.resize(_table_resource.row_count)
        _unused_row_indexes.sort()
        var dst_index:int = 0
        var next_unused_row_index:int = _unused_row_indexes[0]
        var unused_row_indexes_index:int = 1;
        for row_index:int in _unused_row_indexes.size() + _table_resource.row_count:
            if row_index == next_unused_row_index:
                next_unused_row_index = _unused_row_indexes[unused_row_indexes_index]
                unused_row_indexes_index += 1
            else:
                result[dst_index] = _get_row(row_index)
                dst_index += 1
        return result

    func _get_row(row_index:int) -> Object:
        # TODO cache and add keys
        var obj:Object = _schema_class.new()
        for resource:PropertyResource in _table_resource.property_resources.values():
            obj.set(resource.prop_name, resource.get_value(row_index))
        return obj

    func delete_all_rows() -> bool:
        # TODO check integrity
        for resource:PropertyResource in _table_resource.property_resources.values():
            resource.delete_all_rows()
        return true 

    func _delete_row(row_index:int):
        _unused_row_indexes.append(row_index)
        _table_resource.row_count -= 1
        for resource:PropertyResource in _table_resource.property_resources.values():
            resource.delete_row(row_index)

    func add_row(row:Object):
        var row_index:int = _table_resource.row_count
        if _unused_row_indexes.size() > 0:
            row_index = _unused_row_indexes[_unused_row_indexes.size() - 1]
            _unused_row_indexes.resize(_unused_row_indexes.size() - 1)
        for resource:PropertyResource in _table_resource.property_resources.values():
            resource.set_value(row_index, row.get(resource.prop_name))
        _table_resource.row_count += 1

    func remove_unused_rows():
        if _unused_row_indexes.size() == 0: return
        _unused_row_indexes.sort()
        for resource:PropertyResource in _table_resource.property_resources.values():
            resource.remove_unused_rows(_unused_row_indexes)
        _unused_row_indexes.clear()
        

@export var tables:Dictionary = {}

func table(name:StringName, schema_class:Variant, options:Dictionary = {}) -> IrieDataTable:
    return IrieDataTable.new(self, name, schema_class, options)
