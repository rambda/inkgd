# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkObject

class_name InkVariableReference

# ############################################################################ #

# String
var name := ""

# InkPath
var path_for_count: InkPath = null

# Container?
var container_for_count: InkContainer:
	get:
		if not path_for_count:
			return null
		return self.resolve_path(path_for_count).container

# String?
var path_string_for_count: String:
	get:
		if path_for_count == null:
			return ""

		return compact_path_string(path_for_count)
	set(value):
		if value.is_empty():
			path_for_count = null
		else:
			path_for_count = InkPath.new_with_components_string(value)

# ############################################################################ #

func _init(name: String = ""):
	if name:
		self.name = name

# ############################################################################ #

func _to_string() -> String:
	if !name.is_empty():
		return "var(%s)" % name
	else:
		var path_str = self.path_string_for_count
		return "read_count(%s)" % path_str

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type: String) -> bool:
	return type == "VariableReference" || super.is_class(type)

func get_class() -> String:
	return "VariableReference"
