package gui_sdl

import "base:runtime"
string_to_cstring :: proc(s: string) -> cstring {
	buf := make([]u8, len(s) + 1)
	runtime.copy_from_string(buf, s)
	buf[len(s)] = 0
	return cstring(&buf[0])
}
