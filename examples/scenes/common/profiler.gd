# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

extends RefCounted

class_name InkGDProfiler

# ############################################################################ #
# Properties
# ############################################################################ #

var milliseconds_elaspsed: int :
	get:
		return milliseconds_elaspsed # TODOConverter40 Copy here content of get_milliseconds_elaspsed 
	set(mod_value):
		mod_value  # TODOConverter40  Non existent set function
func get_milliseconds_elaspsed():
	if _start_time == -1 || _end_time == -1:
		return 0

	return _end_time - _start_time


# ############################################################################ #
# Private properties
# ############################################################################ #

var _start_time: int = -1
var _end_time: int = -1


# ############################################################################ #
# Methods
# ############################################################################ #

func start():
	_start_time = Time.get_ticks_msec()


func stop():
	_end_time = Time.get_ticks_msec()


func reset():
	_start_time = 0
	_end_time = 0
