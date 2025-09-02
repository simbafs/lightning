package main

import (
	rl "github.com/gen2brain/raylib-go/raylib"
)

type Img struct {
	p          rl.Vector2 // position
	scale      float32    // scale of the image
	scaleSpeed float32    // how fast the scale change, 0 => no change
	rotate     float32    // the rotating degree of the image
	rotateRate float32    // how fast the rotate change
}

func main() {
	var width int32 = 800
	var height int32 = 600

	rl.SetTraceLogLevel(rl.LogWarning)

	rl.SetConfigFlags(rl.FlagWindowTransparent)
	rl.SetTargetFPS(60)

	rl.InitWindow(width, height, "Lightning Talk")
	defer rl.CloseWindow()

	rl.InitAudioDevice()
	defer rl.CloseAudioDevice()

	sound := loadSound("res/sound.wav")
	image := loadTexture("res/sitcon.png")
	icon := loadImage("res/icon.png")

	rl.SetWindowIcon(*icon)

	var images []*Img
	lastSpawn := 0.0
	spawnInterval := 1.0 / 10

	for !rl.WindowShouldClose() {
		switch {
		case rl.IsKeyPressed(rl.KeyF), rl.IsMouseButtonPressed(rl.MouseButtonMiddle):
			rl.ToggleFullscreen()
		case rl.IsKeyPressed(rl.KeyC), rl.IsKeyPressed(rl.KeyPageDown), rl.IsMouseButtonPressed(rl.MouseButtonRight):
			images = nil
		case rl.IsMouseButtonDown(rl.MouseLeftButton), rl.IsKeyDown(rl.KeyPageUp):
			now := rl.GetTime()
			if now-lastSpawn < spawnInterval {
				break
			}
			rl.PlaySound(sound)
			mousePos := rl.GetMousePosition()

			rotateRate := float32(5)
			if len(images)%2 == 0 {
				rotateRate = -5
			}

			images = append(images, &Img{
				p:          mousePos,
				scale:      0.1 * float32(len(images)+1),
				scaleSpeed: 0.01 * float32(len(images)+1),
				rotate:     0,
				rotateRate: rotateRate,
			})
			lastSpawn = now
		}

		for _, img := range images {
			if img.scale <= 10 {
				img.scale += img.scaleSpeed
			}

			img.rotate += img.rotateRate
		}

		rl.BeginDrawing()
		rl.ClearBackground(rl.Blank)

		for _, img := range images {
			w := float32(image.Width)
			h := float32(image.Height)

			src := rl.Rectangle{
				X:      0,
				Y:      0,
				Width:  w,
				Height: h,
			}
			dest := rl.Rectangle{
				X:      img.p.X,
				Y:      img.p.Y,
				Width:  w * img.scale,
				Height: h * img.scale,
			}
			origin := rl.Vector2{
				X: 550 * img.scale,
				Y: 990 * img.scale,
			}

			rl.DrawTexturePro(image, src, dest, origin, img.rotate, rl.White)
		}

		rl.EndDrawing()
	}
}
