# ############################################################################ #
# Copyright © 2015-present inkle Ltd.
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

# Using an dictionary as the backing structure for a not-too-bad, super-simple
# set. The Ink runtime doesn't use C#'s HashSet full potential, so this trick
# should be good enough for the use-case.

# This simple set is designed to hold Strings only.

tool
extends Reference

# ############################################################################ #
# Self-reference
# ############################################################################ #

var StringSet setget , get_StringSet
func get_StringSet():
	return load("res://addons/inkgd/runtime/extra/string_set.gd")

# ############################################################################ #

var _dictionary = {}

# ############################################################################ #

func clear() -> void:
	_dictionary.clear()

func duplicate():
	var set = StringSet.new()
	set._dictionary = self._dictionary.duplicate()
	return set

func enumerate() -> Array:
	return _dictionary.keys()

func empty() -> bool:
	return _dictionary.empty()

func contains(element: String) -> bool:
	return _dictionary.has(element)

func contains_all(elements: Array) -> bool:
	return _dictionary.has_all(elements)

func size() -> int:
	return _dictionary.size()

func to_array() -> Array:
	return _dictionary.keys()

func append(value: String) -> void:
	_dictionary[value] = null

func erase(value: String) -> bool:
	return _dictionary.erase(value)
