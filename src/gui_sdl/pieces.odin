package gui_sdl

import "core:fmt"
import SDL "vendor:sdl2"
import "vendor:sdl2/image"
import "core:strings"

PieceTextures :: struct {
    names: []string,
    textures: [dynamic]^SDL.Texture,
}

load_piece_textures :: proc(renderer: ^SDL.Renderer) -> PieceTextures {
    names := []string{
        "w_pawn", "w_rook", "w_knight", "w_bishop", "w_queen", "w_king",
        "b_pawn", "b_rook", "b_knight", "b_bishop", "b_queen", "b_king",
    }

    textures: [dynamic]^SDL.Texture = make([dynamic]^SDL.Texture, len(names))

    for i in 0..<len(names) {
        name := names[i]
        path_buf := make([]u8, 1024)
        path := fmt.bprintf(path_buf, "assets/pieces/%s_png_256px.png", name)
        surface := image.Load(string_to_cstring(path))
        if surface == nil {
            SDL.Log("Failed to load surface: %s", path)
            continue
        }

        texture := SDL.CreateTextureFromSurface(renderer, surface)
        SDL.FreeSurface(surface)

        if texture == nil {
            SDL.Log("Failed to create texture: %s", path)
            continue
        }

        textures[i] = texture
    }

    return PieceTextures{
        names = names,
        textures = textures,
    }
}

get_piece_texture :: proc(pt: PieceTextures, name: string) -> ^SDL.Texture {
    for i in 0..<len(pt.names) {
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
