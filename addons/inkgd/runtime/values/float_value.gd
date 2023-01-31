# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkValue

class_name InkFloatValue

# ############################################################################ #

var value: float

func get_value_type() -> ValueType:
	return ValueType.FLOAT

func get_is_truthy() -> bool:
	return value != 0.0

func _init(v: float):
	value = v

# The method takes a `StoryErrorMetadata` object as a parameter that
# doesn't exist in upstream. The metadat are used in case an 'exception'
# is raised. For more information, see story.gd.
func cast(new_type, metadata: StoryErrorMetadata = null):
	if new_type == self.value_type:
		return self

	if new_type == ValueType.BOOL:
		return InkBoolValue.new(false if value == 0 else true)

	if new_type == ValueType.INT:
		return InkIntValue.new(int(value))

	if new_type == ValueType.STRING:
		return InkStringValue.new(str(value)) # TODO: Check formating

	Utils.throw_story_exception(bad_cast_exception_message(new_type), false, metadata)
	return null

# ######################################################################## #
# GDScript extra methods
# ######################################################################## #

func is_class(type):
	return type == "FloatValue" || super.is_class(type)

func get_class():
	return "FloatValue"
