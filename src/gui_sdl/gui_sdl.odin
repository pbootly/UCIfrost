package gui_sdl

import "../chess/board"
import "core:c"
import "core:fmt"
import "core:log"
import "core:strings"
import SDL "vendor:sdl2"
import "vendor:sdl2/ttf"

GuiSDL :: struct {
	window:   ^SDL.Window,
	renderer: ^SDL.Renderer,
	font:     ^ttf.Font,
}

Square :: struct {
	rank: i32,
	file: i32,
}

new_gui :: proc() -> GuiSDL {
	return GuiSDL{}
}

init_sdl :: proc(self: ^GuiSDL) -> (ok: bool) {

	if sdl_res := SDL.Init(SDL.INIT_VIDEO); sdl_res < 0 {
		SDL.Log("Failed to init SDL: %s", SDL.GetError())
		return false
	}

	if ttf_res := ttf.Init(); ttf_res != 0 {
		SDL.Log("Failed to init SDL_ttf: %s", ttf.GetError())
		return false
	}

	self.window = SDL.CreateWindow(
		"UCIFrost",
		SDL.WINDOWPOS_CENTERED,
		SDL.WINDOWPOS_CENTERED,
		800,
		800,
		SDL.WINDOW_SHOWN,
	)

	if self.window == nil {
		SDL.Log("Failed to create window: %s", SDL.GetError())
		return false
	}

	self.font = init_font("assets/fonts/DejaVuSans.ttf", 18)
	if self.font == nil {
		SDL.Log("Font loading failed, text rendering will not work")
	}
	self.renderer = SDL.CreateRenderer(self.window, -1, {.ACCELERATED, .PRESENTVSYNC})
	return self.renderer != nil
}

position_to_square :: proc(self: ^GuiSDL, mouse_x: i32, mouse_y: i32) -> Square {
	window_width, window_height: i32 = 0, 0
	SDL.GetWindowSize(self.window, &window_width, &window_height)
	square_size := window_width / 8 // Assumes width and height are always equal
	rank := mouse_y / square_size
	file := mouse_x / square_size
	return {rank, file}
}

square_to_algebraic :: proc(square: Square) -> string {
	ranks := "abcdefgh"
	file := ranks[square.file]
	rank := 8 - square.rank

	buf := make([]u8, 2)
	fmt.bprintf(buf, "%c%d", file, rank)

	return string(buf)
}

draw_board :: proc(self: ^GuiSDL, board: ^board.Board, pieces: ^PieceTextures) {
	square_size := board.size / 8

	// Get valid destination squares for highlighting
	valid_destinations := get_valid_destination_squares()
	defer delete(valid_destinations)

	for y := 0; y < 8; y += 1 {
		for x := 0; x < 8; x += 1 {
			// Check if this square is selected
			current_square := square_to_algebraic({i32(y), i32(x)})
			is_selected := selected_square == current_square

			// Check if this square is a valid move destination
			is_valid_destination := false
			for dest in valid_destinations {
				if current_square == dest {
					is_valid_destination = true
					break
				}
			}

			if (x + y) % 2 == 0 {
				// Light squares - highlight if selected or valid destination
				if is_selected {
					SDL.SetRenderDrawColor(self.renderer, 255, 255, 0, 255) // Yellow highlight for selected
				} else if is_valid_destination {
					SDL.SetRenderDrawColor(self.renderer, 144, 238, 144, 255) // Light green for valid moves
				} else {
					SDL.SetRenderDrawColor(self.renderer, 240, 217, 181, 255) // Normal light
				}
			} else {
				// Dark squares - highlight if selected or valid destination
				if is_selected {
					SDL.SetRenderDrawColor(self.renderer, 255, 215, 0, 255) // Golden highlight for selected
				} else if is_valid_destination {
					SDL.SetRenderDrawColor(self.renderer, 50, 205, 50, 255) // Green for valid moves
				} else {
					SDL.SetRenderDrawColor(self.renderer, 181, 136, 99, 255) // Normal dark
				}
			}

			rect := SDL.Rect {
				x = c.int(x * square_size),
				y = c.int(y * square_size),
				w = c.int(square_size),
				h = c.int(square_size),
			}
			SDL.RenderFillRect(self.renderer, &rect)
			font_color := SDL.Color {
				r = 0,
				g = 0,
				b = 0,
				a = 255,
			}
			if y == 7 {
				files := "abcdefgh"
				file_letter := string([]u8{files[x]})
				render_text(
					self,
					file_letter,
					x * square_size + 5,
					y * square_size + square_size - 20,
					font_color,
				)
			}

			if x == 0 {
				buf := make([]u8, 1)
				rank_number := fmt.bprintf(buf, "%d", 8 - y)
				render_text(self, rank_number, 5, y * square_size + 5, font_color)
			}
			piece_name := board.pieces[y * 8 + x]
			if piece_name != "" {
				texture := get_piece_texture(pieces^, piece_name)
				if texture != nil {
					dst_rect := SDL.Rect {
						x = c.int(x * square_size),
						y = c.int(y * square_size),
						w = c.int(square_size),
						h = c.int(square_size),
					}
					SDL.RenderCopy(self.renderer, texture, nil, &dst_rect)
				} else {
					SDL.Log("Missing texture for %s", piece_name)
				}
			}
		}
	}
	SDL.RenderPresent(self.renderer)
}

shutdown :: proc(self: ^GuiSDL) {
	SDL.DestroyRenderer(self.renderer)
	SDL.DestroyWindow(self.window)
	SDL.Quit()
}
