package main

import (
	"embed"
	"io"

	rl "github.com/gen2brain/raylib-go/raylib"
)

//go:embed all:res
var resFS embed.FS

func loadRes(path string) []byte {
	file, err := resFS.Open(path)
	if err != nil {
		panic(err)
	}

	b, err := io.ReadAll(file)
	if err != nil {
		panic(err)
	}

	return b
}

func loadImage(path string) *rl.Image {
	b := loadRes(path)
	image := rl.LoadImageFromMemory(".png", b, int32(len(b)))
	return image
}

func loadTexture(path string) rl.Texture2D {
	b := loadRes(path)
	image := rl.LoadImageFromMemory(".png", b, int32(len(b)))
	texture := rl.LoadTextureFromImage(image)
	return texture
}

func loadSound(path string) rl.Sound {
	b := loadRes(path)
	wav := rl.LoadWaveFromMemory(".wav", b, int32(len(b)))
	sound := rl.LoadSoundFromWave(wav)
	return sound
}
