package main

import (
	rl "github.com/gen2brain/raylib-go/raylib"
)

type Img struct {
	p          rl.Vector2
	v          rl.Vector2
	scale      float32
	scaleSpeed float32
	rotate     float32
	rotateDirc float32
}

func getWidth() float32 {
	if rl.IsWindowFullscreen() {
		// BUG: this is wrong
		return float32(rl.GetMonitorWidth(rl.GetCurrentMonitor())) * rl.GetWindowScaleDPI().X
	}
	return float32(rl.GetScreenWidth())
}

func getHeight() float32 {
	if rl.IsWindowFullscreen() {
		// BUG: this is wrong
		return float32(rl.GetMonitorHeight(rl.GetCurrentMonitor())) * rl.GetWindowScaleDPI().Y
	}
	return float32(rl.GetScreenHeight())
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

			rotateDir := float32(1)
			if len(images)%2 == 0 {
				rotateDir = -1
			}

			images = append(images, &Img{
				p:          mousePos,
				v:          rl.NewVector2(10, 10),
				scale:      0.1 * float32(len(images)+1),
				scaleSpeed: 0.01 * float32(len(images)+1),
				rotate:     0,
				rotateDirc: rotateDir,
			})
			lastSpawn = now
		}

		for _, img := range images {
			// w := float32(0) // float32(img.Width) * pos.scale
			// h := float32(0) // float32(img.Height) * pos.scale
			// sw := getWidth()
			// sh := getHeight()
			//
			// pos.p = rl.Vector2Add(pos.p, pos.v)
			// if pos.p.X+w > sw {
			// 	pos.p.X = sw - w
			// 	pos.v.X *= -1
			// } else if pos.p.X < 0 {
			// 	pos.p.X = 0
			// 	pos.v.X *= -1
			// }
			//
			// if pos.p.Y+h > sh {
			// 	pos.p.Y = sh - h
			// 	pos.v.Y *= -1
			// } else if pos.p.Y < 0 {
			// 	pos.p.Y = 0
			// 	pos.v.Y *= -1
			// }

			if img.scale <= 10 {
				img.scale += img.scaleSpeed
			}

			img.rotate += 5 * img.rotateDirc
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
