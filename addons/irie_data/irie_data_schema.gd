class_name IrieDataSchema
extends Resource


func _get_all_rows(row_type:Variant) -> Array[IrieDataRow]:
    return []


func _get_row(ref:IrieDataRef) -> IrieDataRow:
    return null

func _add_row(row_type:Variant) -> IrieDataRef:
    return null

func _delete_row(ref:IrieDataRef) -> bool:
    return false

func _save_row(row:IrieDataRow) -> bool:
    return false