package process

import "core:bufio"
import "core:log"
import os "core:os/os2"

SubProcess :: struct {
	process: os.Process,
	pipes:   ProcessPipes,
	name:    string,
}

ProcessPipes :: struct {
	stdout_read:  ^os.File,
	stdout_write: ^os.File,
	stdin_read:   ^os.File,
	stdin_write:  ^os.File,
}

new_process :: proc() -> SubProcess {
	return SubProcess{}
}

init_process :: proc(self: ^SubProcess) -> (ok: bool, err: os.Error) {
	stdout_read, stdout_write := os.pipe() or_return
	stdin_read, stdin_write := os.pipe() or_return
	p: os.Process;{
		defer os.close(stdout_write)
		p = os.process_start(
			{command = {self.name}, stdout = stdout_write, stdin = stdin_read},
		) or_return
	}
	self.process = p
	self.pipes = ProcessPipes {
		stdout_read  = stdout_read,
		stdout_write = stdout_write,
		stdin_read   = stdin_read,
		stdin_write  = stdin_write,
	}
	log.debug("process start:", self.process.pid)
	return true, nil
}

shutdown :: proc(self: ^SubProcess) {
	defer os.close(self.pipes.stdout_write)
	defer os.close(self.pipes.stdin_read)
	defer os.close(self.pipes.stdin_write)
	log.debug("process shutdown:", self.process.pid)
}
