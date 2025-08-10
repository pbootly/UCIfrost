package main

import "../src/chess/board"
import "../src/gui_sdl"
import "../src/process"
import "../src/uci"
import "core:log"
import os "core:os/os2"
import "core:time"

main :: proc() {
	context.logger = log.create_console_logger()

	tick: time.Tick = time.Tick{}
	time.tick_lap_time(&tick)
	gui := gui_sdl.new_gui()
	if res := gui_sdl.init_sdl(&gui); !res {
		log.errorf("SDL initialization failed")
		return
	}
	defer gui_sdl.shutdown(&gui)

	pieces := gui_sdl.load_piece_textures(gui.renderer)

	elapsed := time.tick_lap_time(&tick)
	log.debug("SDL initialized in", elapsed)

	e := process.new_process()
	e.name = "stockfish"
	if res, err := process.init_process(&e); !res || err != nil {
		log.errorf("engine process initalization failed")
		return
	}
	if !uci.init(&e.pipes) {
		log.error("failed to initialize UCI")
		return
	}
	elapsed = time.tick_lap_time(&tick)
	log.debug("Engine initialized in", elapsed)

	running := true
	b := board.Board{}
	b.size = 800
	board.init_board(&b)

	target_fps := 60
	frame_duration := time.Duration(1_000_000_000 / target_fps)
	for running {
		elapsed := time.tick_lap_time(&tick)
		running = gui_sdl.handle_events(&gui)
		gui_sdl.draw_board(&gui, &b, &pieces)
		if elapsed < frame_duration {
			time.sleep(frame_duration - elapsed)
		}
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
