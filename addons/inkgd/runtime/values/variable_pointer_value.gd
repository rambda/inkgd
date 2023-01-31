# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkValue

class_name InkVariablePointerValue

# ############################################################################ #

var value: String = ""

var variable_name: String :
	get:
		return value
	set(value):
		self.value = value


func get_value_type() -> ValueType:
	return ValueType.VARIABLE_POINTER

func get_is_truthy() -> bool:
	Utils.throw_exception("Shouldn't be checking the truthiness of a variable pointer")
	return false

var context_index := 0 # int

func _init():
	pass

# The method takes a `StoryErrorMetadata` object as a parameter that
# doesn't exist in upstream. The metadat are used in case an 'exception'
# is raised. For more information, see story.gd.
func cast(new_type, metadata: StoryErrorMetadata = null):
	if new_type == self.value_type:
		return self

	Utils.throw_story_exception(bad_cast_exception_message(new_type), false, metadata)
	return null

func _to_string() -> String:
	return "VariablePointerValue(" + self.variable_name + ")"

func copy():
	return InkVariablePointerValue.new_with_context(self.variable_name, context_index)

# ######################################################################## #
# GDScript extra methods
# ######################################################################## #

func is_class(type):
	return type == "VariablePointerValue" || super.is_class(type)

func get_class():
	return "VariablePointerValue"

static func new_with_context(variable_name, context_index = -1):
	var value = InkVariablePointerValue.new()
	value.value = variable_name
	value.context_index = context_index
	return value
