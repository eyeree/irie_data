@tool
class_name IrieDataSet
extends Resource

@export_storage var tables:Dictionary = {}

func table(table_name:StringName, schema_class:Variant, options:Dictionary = {}) -> IrieDataTable:
    var table_resource:IrieDataTable = tables.get(table_name)
    if table_resource == null:
        table_resource = IrieDataTable.new()
        table_resource._table_name = table_name
        tables[table_name] = table_resource
    table_resource._set_schema_class(schema_class, options)
    return table_resource

func table_key() -> Dictionary:
    return { 'key': true }

func table_auto_key() -> Dictionary:
    return { 'key': true, 'auto': true }

func table_relation(target_table:IrieDataTable) -> Dictionary:
    return { 'relation': target_table }
