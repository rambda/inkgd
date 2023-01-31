# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkValue

class_name InkDivertTargetValue

# ############################################################################ #

var value: InkPath

var target_path: InkPath:
	get:
		return value
	set(value):
		self.value = value


func get_value_type():
	return ValueType.DIVERT_TARGET

func get_is_truthy() -> bool:
	Utils.throw_exception("Shouldn't be checking the truthiness of a divert target")
	return false

func _init(v: InkPath = null):
	value = v

# The method takes a `StoryErrorMetadata` object as a parameter that
# doesn't exist in upstream. The metadat are used in case an 'exception'
# is raised. For more information, see story.gd.
func cast(new_type, metadata: StoryErrorMetadata = null):
	if new_type == self.value_type:
		return self

	Utils.throw_story_exception(bad_cast_exception_message(new_type), false, metadata)
	return null

func _to_string() -> String:
	return "DivertTargetValue(" + self.target_path._to_string() + ")"

# ######################################################################## #
# GDScript extra methods
# ######################################################################## #

func is_class(type):
	return type == "DivertTargetValue" || super.is_class(type)

func get_class():
	return "DivertTargetValue"
