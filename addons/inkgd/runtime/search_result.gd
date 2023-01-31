# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

# ############################################################################ #
# !! VALUE TYPE
# ############################################################################ #

# Search results are never duplicated / passed around so they don't need to
# be either immutable or have a 'duplicate' method.

extends InkBase

class_name InkSearchResult

# ############################################################################ #

var obj: InkObject = null # InkObject
var approximate := false # bool

var correct_obj: InkObject:
	get = get_correct_obj # InkObject
func get_correct_obj():
	return null if approximate else obj

var container: InkContainer:
	get:
		return obj as InkContainer

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type: String) -> bool:
	return type == "SearchResult" || super.is_class(type)

func get_class() -> String:
	return "SearchResult"
