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

    @export_storage var property_name:String
    @export_storage var property_type:PropertyType

    # Virtual methods that should be overridden in derived classes. The ones that
    # refer to the property type are commented out. If generic classes are ever
    # supported, one could be used here.

    func is_for_prop(prop:Dictionary) -> bool:
        push_error('must override is_for_prop in PropertyResource derived class')
        return false

    func delete_all_rows() -> void:
        push_error('must override delete_all_rows in PropertyResource derived class')

    func delete_row(row_index:int) -> void:
        push_error('must override delete_row in PropertyResource derived class')
        
    # func get_value(row_index:int) -> T:
    #     push_error('must override get_value in PropertyResource derived class')

    # func set_value(row_index:int, new_value:T) -> void:
    #     push_error('must override set_value in PropertyResource derived class')



class PropertyResourceBool:
    extends PropertyResource

    static func for_prop(prop:Dictionary, default_value:Variant, row_count:int) -> PropertyResourceBool:
        var resource:PropertyResourceBool = PropertyResourceBool.new()
        resource.property_name = prop['name']
        resource.property_type = PropertyType.BOOL
        if row_count > 0:
            resource.data.resize(row_count)
            if resource.data[0] != default_value:
                for i:int in row_count:
                    resource.data[i] = default_value
        return resource

    @export_storage var data:PackedByteArray = [] 

    func get_value(row_index:int) -> bool:
        return data[row_index]

    func set_value(row_index:int, new_value:bool) -> void:
        data[row_index] = new_value   

    func delete_all_rows() -> void:
        data.clear()

    func delete_row(row_index:int) -> void:
        data.remove_at(row_index)

    func is_for_prop(prop:Dictionary) -> bool:
        return property_name == prop['name'] && prop['type'] == TYPE_BOOL


class PropertyResourceColor:
    extends PropertyResource

    static func for_prop(prop:Dictionary, default_value:Variant, row_count:int) -> PropertyResourceColor:
        var resource:PropertyResourceColor = PropertyResourceColor.new()
        resource.property_name = prop['name']
        resource.property_type = PropertyType.COLOR
        if row_count > 0:
            resource.data.resize(row_count)
            if resource.data[0] != default_value:
                for i:int in row_count:
                    resource.data[i] = default_value
        return resource

    @export_storage var data:PackedColorArray = [] 
    
    func get_value(row_index:int) -> Color:
        return data[row_index]

    func set_value(row_index:int, new_value:Color) -> void:
        data[row_index] = new_value

    func delete_row(row_index:int) -> void:
        data.remove_at(row_index)
    
    func delete_all_rows() -> void:
        data.clear()

    func is_for_prop(prop:Dictionary) -> bool:
        return property_name == prop['name'] && prop['type'] == TYPE_COLOR


class PropertyResourceEnum:
    extends PropertyResource

    @export_storage var data:PackedByteArray = []
    @export_storage var enum_name:String = ''

    static func is_enum_prop(prop:Dictionary):
        return false

    static func for_prop(prop:Dictionary, default_value:Variant, row_count:int) -> PropertyResourceEnum:
        var resource:PropertyResourceEnum = PropertyResourceEnum.new()
        resource.property_name = prop['name']
        resource.property_type = PropertyType.ENUM
        resource.enum_name = prop['class_name']
        if row_count > 0:
            resource.data.resize(row_count)
            if resource.data[0] != default_value:
                for i:int in row_count:
                    resource.data[i] = default_value
        return resource

    func get_value(row_index:int) -> float:
        return data[row_index]

    func set_value(row_index:int, new_value:float) -> void:
        data[row_index] = new_value

    func delete_row(row_index:int) -> void:
        data.remove_at(row_index)
    

    func delete_all_rows() -> void:
        data.clear()

    func is_for_prop(prop:Dictionary) -> bool:
        return property_name == prop['name'] && prop['type'] == TYPE_INT && prop['class_name'] == enum_name


class PropertyResourceFloat:
    extends PropertyResource

    static func for_prop(prop:Dictionary, default_value:Variant, row_count:int) -> PropertyResourceFloat:
        var resource:PropertyResourceFloat = PropertyResourceFloat.new()
        resource.property_name = prop['name']
        resource.property_type = PropertyType.FLOAT
        if row_count > 0:
            resource.data.resize(row_count)
            if resource.data[0] != default_value:
                for i:int in row_count:
                    resource.data[i] = default_value
        return resource

    @export_storage var data:PackedFloat64Array = []

    func _init() -> void:
        property_type = PropertyType.FLOAT

    func get_value(row_index:int) -> float:
        return data[row_index]

    func set_value(row_index:int, new_value:float) -> void:
        data[row_index] = new_value

    func delete_row(row_index:int) -> void:
        data.remove_at(row_index)     

    func delete_all_rows() -> void:
        data.clear()

    func is_for_prop(prop:Dictionary) -> bool:
        return property_name == prop['name'] && prop['type'] == TYPE_FLOAT


class PropertyResourceString:
    extends PropertyResource

    static func for_prop(prop:Dictionary, default_value:Variant, row_count:int) -> PropertyResourceString:
        var resource:PropertyResourceString = PropertyResourceString.new()
        resource.property_name = prop['name']
        resource.property_type = PropertyType.STRING
        if row_count > 0:
            resource.data.resize(row_count)
            if resource.data[0] != default_value:
                for i:int in row_count:
                    resource.data[i] = default_value
        return resource

    @export_storage var data:PackedStringArray = []

    func get_value(row_index:int) -> String:
        return data[row_index]

    func set_value(row_index:int, new_value:String) -> void:
        data[row_index] = new_value

    func delete_row(row_index:int) -> void:
        data.remove_at(row_index)

    func delete_all_rows() -> void:
        data.clear()

class IrieDataTable:
    extends Resource

    var table_name:String:
        get():
            return _table_name

    @export_storage var _table_name:String
    @export_storage var _property_resources:Dictionary = {}
    @export_storage var _row_count:int = 0
    @export_storage var _key_to_row_index_map:Dictionary = {}

    var _schema_class:Variant
    var _schema_options:Dictionary
    var _key_property_name:StringName = ''
    var _key_to_object_map:Dictionary = {}

    func _set_schema_class(schema_class:Variant, schema_options:Dictionary):

        if schema_class is not GDScript:
            push_error('schema_class must be a GDScript defined class')
            return

        _schema_class = schema_class
        _schema_options = schema_options

        _update_property_resources()


    func _update_property_resources():

        var unused_property_resource_names:Array = _property_resources.keys()

        _key_property_name = ''

        for prop in _schema_class.get_script_property_list():
            var prop_name:String = prop['name']
            var prop_usage:PropertyUsageFlags = prop['usage']
            var prop_options:Dictionary = _schema_options[prop_name]
            if prop_usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
                var is_new:bool = _update_property_resource(prop)
                if not is_new:
                    unused_property_resource_names.erase(prop_name)
                if prop_options.get('key', false):
                    _key_property_name = prop_name

        for unused_property_resource_name in unused_property_resource_names:
            prints('  removed from property map', unused_property_resource_name)
            _property_resources.erase(unused_property_resource_name)

        if _key_property_name == '':
            push_error('No key property specified for table %s' % table_name)


    func _update_property_resource(prop:Dictionary) -> bool:
        var prop_name:String = prop['name']
        var resource = _property_resources.get(prop_name)
        if not resource:
            prints('  add to property map', prop)
            resource = _create_resource_for_property(prop)
            _property_resources[prop_name] = resource
            return true
        else:
            prints('  found in property map', prop)
            if not resource.is_for_prop(prop):
                push_error('Table %s property %s schema class mismatch: %s' % [table_name, resource, prop])
            return false


    func _create_resource_for_property(prop:Dictionary) -> PropertyResource:
        var prop_name:String = prop['name']
        var prop_type:Variant.Type = prop['type']
        var prop_usage:PropertyUsageFlags = prop['usage']
        var prop_options:Dictionary = _schema_options[prop_name]
        var default_value = _schema_class.get_property_default_value(prop_name)
        var resource:PropertyResource = null
        match prop_type:
            TYPE_BOOL:
                resource = PropertyResourceBool.for_prop(prop, default_value, _row_count)
            TYPE_COLOR:
                resource = PropertyResourceColor.for_prop(prop, default_value, _row_count)
            TYPE_FLOAT:
                resource = PropertyResourceFloat.for_prop(prop, default_value, _row_count)
            TYPE_STRING:
                resource = PropertyResourceString.for_prop(prop, default_value, _row_count)
            TYPE_INT when prop_usage & PROPERTY_USAGE_CLASS_IS_ENUM:
                resource = PropertyResourceEnum.for_prop(prop, default_value, _row_count)
            _:
                push_error('Table %s schema class unsupported property: %s' % [table_name, prop])
        return resource


    func _verify_relations():
        pass


    func get_row_count() -> int:
        return _row_count


    func get_all_rows() -> Array[Object]:
        var result:Array[Object] = []
        result.resize(_row_count)
        var dst_index:int = 0
        for key in _key_to_row_index_map.keys():
            var row_object:Object = get_row(key)
            result[dst_index] = row_object
            dst_index += 1
        return result


    func get_row(key:Variant) -> Object:
        var row_object:Object = _key_to_object_map.get(key, null)
        if row_object == null:
            var row_index:int = _key_to_row_index_map.get(key, -1)
            if row_index == -1:
                push_error('There is no row with key %s in table %s' % [key, _table_name])
                return null
            row_object = _schema_class.new()
            for resource:PropertyResource in _property_resources.values():
                row_object.set(resource.property_name, resource.get_value(row_index))
        return row_object


    func delete_all_rows():
        _row_count = 0
        _key_to_row_index_map.clear()
        _key_to_object_map.clear()
        for resource:PropertyResource in _property_resources.values():
            resource.delete_all_rows()


    func delete_row(key:Variant) -> bool:
        var row_index:int = _key_to_row_index_map.get(key, -1)
        if row_index == -1: 
            return false
        else:

            # remove key for deleted row from maps
            _key_to_row_index_map.erase(key)
            _key_to_object_map.erase(key)

            # update row index map for indexes above the one deleted
            for other_key in _key_to_row_index_map.keys():
                var other_row_index = _key_to_row_index_map[other_key]
                if other_row_index > row_index:
                    _key_to_row_index_map[other_key] = other_row_index - 1

            # remove deleted row from all property resources
            for resource:PropertyResource in _property_resources.values():
                resource.delete_row(row_index)

            # one fewer rows now
            _row_count -= 1

            return true


    func add_row(row_object:Object) -> bool:
        var key:Variant = row_object.get(_key_property_name)
        if _key_to_row_index_map.has(key):
            push_error('An row with key %s already exists in table %s' % [key, _table_name])
            return false
        else:

            # new rows are appended
            var row_index:int = _row_count

            # add key for added row to maps 
            _key_to_row_index_map[key] = row_index
            _key_to_object_map[key] = row_object

            # set value in property resource for added row
            for resource:PropertyResource in _property_resources.values():
                resource.set_value(row_index, row_object.get(resource.property_name))

            # one more row now
            _row_count += 1

            return true


    func update_row(row_object:Object) -> bool:
        var key:Variant = row_object.get(_key_property_name)
        var row_index:int = _key_to_row_index_map.get(key, -1)
        if row_index == -1:
            push_error('No row with key %s exists in table %s' % [key, _table_name])
            return false
        else:

            # set value in property resource for updated row
            for resource:PropertyResource in _property_resources.values():
                resource.set_value(row_index, row_object.get(resource.property_name))

            return true


    func add_or_update_row(row_object:Object) -> bool:
        if has_row(row_object.get(_key_property_name)):
            update_row(row_object)
            return false
        else:
            add_row(row_object)
            return true


    func has_row(key:Variant) -> bool:
        return _key_to_row_index_map.has(key)


@export_storage var tables:Dictionary = {}

func table(table_name:StringName, schema_class:Variant, options:Dictionary = {}) -> IrieDataTable:
    var table_resource:IrieDataTable = tables.get(table_name)
    if table_resource == null:
        table_resource = IrieDataTable.new()
        table_resource._table_name = table_name
        tables[table_name] = table_resource
    table_resource._set_schema_class(schema_class, options)
    return table_resource

func schema_key() -> Dictionary:
    return { 'key': true }

func schema_row_id() -> Dictionary:
    return { 'key': true, 'row_id': true }

func schema_relation(target_table:IrieDataTable) -> Dictionary:
    return { 'relation': target_table }