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

# ValueType
var value_type: ValueType :
	get = get_value_type

func get_value_type() -> ValueType:
	return -1


var is_truthy: bool :
	get = get_is_truthy

func get_is_truthy() -> bool:
		return false

# ############################################################################ #

# (ValueType) -> ValueType
func cast(new_type: ValueType) -> InkValue:
	return null

var value_object:
	get:
		return get(&"value")

# ############################################################################ #

# (Variant) -> Value
static func create(val) -> InkValue:
	# Original code lost precision from double to float.
	# But it's not applicable here.

	if val is bool:
		return InkBoolValue.new(val)
	if val is int:
		return InkIntValue.new(val)
	elif val is float:
		return InkFloatValue.new(val)
	elif val is String:
		return InkStringValue.new(val)
	elif val is InkPath:
		return InkDivertTargetValue.new(val)
	elif val is InkList:
		return InkListValue.newh(val)

	return null

func copy() -> InkValue:
	return InkValue.create(self.value_object)

# (Ink.ValueType) -> StoryException
func bad_cast_exception_message(target_class: ValueType) -> String:
	var value_type_name = ValueType.keys()[self.value_type]
	var target_type_name = ValueType.keys()[target_class]
	return "Can't cast %s" % self.value_object + " from " + value_type_name + " to " + target_type_name

# () -> String
func _to_string() -> String:
	var value := get(&"value")
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
