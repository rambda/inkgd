# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkObject

class_name InkChoice

# ############################################################################ #
# Imports
# ############################################################################ #

# ############################################################################ #

var text := "NO_TEXT"

var path_string_on_choice: String:
	get:
		return target_path._to_string()
	set(value):
		target_path = InkPath.new_with_components_string(value)

# String?
var source_path := "NO_SOURCE_PATH"

var index: int = 0

# InkPath?
var target_path: InkPath = null

# CallStack.InkThread?
var thread_at_generation: InkCallStack.InkThread = null

var original_thread_index: int = 0

var is_invisible_default: bool = false

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type):
	return type == "Choice" || super.is_class(type)

func get_class():
	return "Choice"
