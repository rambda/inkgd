# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkValue

class_name InkBoolValue

# ############################################################################ #

var value: bool

func get_value_type() -> ValueType:
	return ValueType.BOOL

func get_is_truthy() -> bool:
	return value

func _init(v: bool):
	value = v

# The method takes a `StoryErrorMetadata` object as a parameter that
# doesn't exist in upstream. The metadat are used in case an 'exception'
# is raised. For more information, see story.gd.
func cast(new_type, metadata: StoryErrorMetadata = null):
	if new_type == self.value_type:
		return self

	if new_type == ValueType.INT:
		return InkIntValue.new(1 if value else 0)

	if new_type == ValueType.FLOAT:
		return InkFloatValue.new(1.0 if value else 0.0)

	if new_type == ValueType.STRING:
		return InkStringValue.new("true" if value else "false")

	Utils.throw_story_exception(bad_cast_exception_message(new_type), false, metadata)
	return null


func _to_string() -> String:
	return "true" if value else "false"

# ######################################################################## #
# GDScript extra methods
# ######################################################################## #

func is_class(type):
	return type == "BoolValue" || super.is_class(type)

func get_class():
	return "BoolValue"
