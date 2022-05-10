extends Node
#this class impliments a generic circular buffer for use
#else where
class_name CircularBuffer

var _buffer : Array setget set_buffer,get_buffer
func set_buffer(val : Array)->void:
	pass
func get_buffer()->Array:
	return []
var _buffer_pointer : int setget set_buffer_pointer,get_buffer_pointer
func set_buffer_pointer(val : int)->void:
	pass
func get_buffer_pointer()->int:
	return _buffer_pointer
func mod(i : int):
	while i < 0:
		i += length()
	return i % length()
func read(idx : int):
	#ensure a negative modulus
	#a bit hacky but it works
	#ensure positive modulus
	return _buffer[mod(idx)]
func read_pointed():
	return _buffer[_buffer_pointer]
#stores the given value into the buffer and incriments
#the pointer with modulus
func push(val):
	var buff_len : int = len(_buffer)
	_buffer[_buffer_pointer % buff_len] = val
	_buffer_pointer = (_buffer_pointer + 1) % buff_len
func length()->int:
	return len(_buffer)
func _init(size : int):
	_buffer.resize(size)
#removes the reference stored in the buffer at that point
func clear(i):
	_buffer[mod(i)] = null