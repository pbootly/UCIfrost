package gui_sdl

import "../chess/pieces"
import "../utils"
import "core:fmt"
import "core:log"
import "core:strings"
import SDL "vendor:sdl2"
import "vendor:sdl2/image"

PieceTextures :: struct {
	names:    []string,
	textures: [dynamic]^SDL.Texture,
}

load_piece_textures :: proc(renderer: ^SDL.Renderer) -> PieceTextures {
	// TODO: Handle png failures
	check_png_support()

	textures: [dynamic]^SDL.Texture = make([dynamic]^SDL.Texture, len(pieces.piece_names))

	for i in 0 ..< len(pieces.piece_names) {
		name := pieces.piece_names[i]
		path_buf := make([]u8, 1024)
		path := fmt.bprintf(path_buf, "assets/pieces/%s_png_256px.png", name)

		SDL.Log("Loading piece texture: %s", path)

		surface := image.Load(utils.string_to_cstring(path))
		if surface == nil {
			SDL.Log("Failed to load surface: %s", path)
			continue
		}

		texture := SDL.CreateTextureFromSurface(renderer, surface)
		SDL.FreeSurface(surface)

		if texture == nil {
			SDL.Log("Failed to create texture from surface for %s: %s", path, SDL.GetError())
			continue
		}

		textures[i] = texture
	}

	return PieceTextures{names = pieces.piece_names, textures = textures}
}

get_piece_texture :: proc(pt: PieceTextures, name: string) -> ^SDL.Texture {
	for i in 0 ..< len(pt.names) {
		if pt.names[i] == name {
			return pt.textures[i]
		}
	}

	return nil
}

free_piece_textures :: proc(pt: ^PieceTextures) {
	for tex in pt.textures {
		if tex != nil {
			SDL.DestroyTexture(tex)
		}
	}
}

check_png_support :: proc() -> bool {
	flags := image.Init(image.INIT_PNG)
	if (flags & image.INIT_PNG) == {} {
		log.error("Failed to init SDL_image with PNG support")
		return false
	}
	return true
}
