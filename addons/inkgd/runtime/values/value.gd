# warning-ignore-all:shadowed_variable
# warning-ignore-all:unused_class_variable
# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkObject

# This is a merge of the original Value class and its Value<T> subclass.
class_name InkValue

# ############################################################################ #
# IMPORTS
# ############################################################################ #

const ValueType = preload("res://addons/inkgd/runtime/values/value_type.gd").ValueType
const InkList = preload("res://addons/inkgd/runtime/lists/ink_list.gd")

# ############################################################################ #
# STATIC REFERENCE
# ############################################################################ #

var value # Variant

# ValueType
var value_type: int :
	get:
		return -1


var is_truthy: bool :
	get:
		return false

# ############################################################################ #

# (ValueType) -> ValueType
func cast(new_type: int) -> InkValue:
	return null

var value_object:
	get:
		return value

# ############################################################################ #

# (Variant) -> Value
func _init_with(val):
	value = val

# (Variant) -> Value
static func create(val) -> InkValue:
	# Original code lost precision from double to float.
	# But it's not applicable here.

	if val is bool:
		return load("res://addons/inkgd/runtime/values/bool_value.gd").new_with(val)
	if val is int:
		return load("res://addons/inkgd/runtime/values/int_value.gd").new_with(val)
	elif val is float:
		return load("res://addons/inkgd/runtime/values/float_value.gd").new_with(val)
	elif val is String:
		return load("res://addons/inkgd/runtime/values/string_value.gd").new_with(val)
	elif Utils.is_ink_class(val, "InkPath"):
		return load("res://addons/inkgd/runtime/values/divert_target_value.gd").new_with(val)
	elif Utils.is_ink_class(val, "InkList"):
		return load("res://addons/inkgd/runtime/values/list_value.gd").new_with(val)

	return null

func copy() -> InkValue:
	return create(self.value_object)

# (Ink.ValueType) -> StoryException
func bad_cast_exception_message(target_class) -> String:
	return "Can't cast " + self.value_object + " from " + self.value_type + " to " + target_class

# () -> String
func _to_string() -> String:
	if value is int || value is float || value is String:
		return str(value)
	else:
		return value._to_string()

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type) -> bool:
	return type == "Value" || super.is_class(type)

func get_class() -> String:
	return "Value"

static func new_with(val) -> InkValue:
	var value = InkValue.new()
	value._init_with(val)
	return value
