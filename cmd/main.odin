package main

import "../src/gui_sdl"
import "../src/process"
import "../src/uci"
import "core:log"
import os "core:os/os2"
import "core:time"

main :: proc() {
	context.logger = log.create_console_logger()

	gui := gui_sdl.new_gui()
	if res := gui_sdl.init_sdl(&gui); !res {
		log.errorf("SDL initialization failed")
	}
	defer gui_sdl.shutdown(&gui)
	e := process.new_process()
	e.name = "stockfish"
	if res, err := process.init_process(&e); !res || err != nil {
		log.errorf("engine process initalization failed")
	}
	if !uci.init(&e.pipes) {
		log.error("failed to initialize UCI")
		return
	}

	running := true
	board := gui_sdl.Board{}
	board.size = 800

	for running {
		running = gui_sdl.handle_events(&gui)
		gui_sdl.draw_board(&gui, &board)
	}

	// TODO - call quit, cleanup pipes, terminate process
	uci.quit(&e.pipes)
	process.shutdown(&e)
	timeout := time.Second * 10
	state, err := os.process_wait(e.process, timeout)
	if err != nil {
		log.errorf("process took longer than timeout", err)
	}
	log.info("engine terminated", state)
}
