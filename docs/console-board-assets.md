# ゲーム機イメージの基板背景

Game Boy/Color Violet/Super Famicomの3種類とも採用。Violetは同日、built-in image_genで元画像の構図・部品を保持しながら紫の色味を少し淡く編集。下記素材リンクは最終版。

## Violet 微調整の最終プロンプト

Use case: lighting-weather. Edit target: the attached violet transparent-game-console circuit board wallpaper. Make ONLY a very subtle color and tonal adjustment: lift the violet translucent resin and purple board tones by approximately 8 percent, and gently soften saturation by approximately 3 percent so the violet feels a little lighter, airier, closer to soft violet. This is a small refinement, not a redesign or pastel recolor. Preserve exactly the composition, every component's placement and proportions, chip geometry, PCB trace paths, plastic ribs, screw posts, reflections, fine material detail and full 4:3 framing. Keep black chips black, metallic components metallic, the quiet upper/central area dark enough for white UI text. No added or removed objects, no blur, no noise, no logos, labels, text or watermark. Keep premium high-resolution photographic quality and convincing transparent violet plastic. No keyboard or UI in the image.

2026-10-10、imagegenスキルのbuilt-in image_genでオリジナル背景を3枚生成。各1448×1086pxのPNGを原寸で同梱。既存の実機基板の厳密な再現ではなく、配色と質感の参照として制作。

- [Game Boy](../DesignSystem/Assets.xcassets/ConsoleGameBoy.imageset/board.png): オリーブ基板、黒いチップ、クリーム色の小部品。
- [Game Boy Color Violet](../DesignSystem/Assets.xcassets/ConsoleViolet.imageset/board.png): 透明な紫樹脂越しに見える内部部品。
- [Super Famicom](../DesignSystem/Assets.xcassets/ConsoleSuperFamicom.imageset/board.png): 深緑の基板と金属部品、4色の小さな部品。
- 同じ背景素材を本体・拡張・StorageTestsに同梱。キー・文字・4色の操作面はネイティブUIで描画し、画像に焼き込まない。
- 上部は暗いグラデーションで文字の可読性を確保。カスタム背景色は色相ブレンドとして反映。

## gb 最終生成プロンプト

Use case: product-mockup. Asset type: high-resolution 4:3 wallpaper background for a production mobile keyboard. Original top-down macro product photograph of a vintage late-1980s handheld-game circuit board, inspired by the original Game Boy internal electronics, not an exact replica. Olive green PCB, tidy fine copper traces, black integrated circuits, tiny cream ceramic capacitors, solder points, restrained burgundy details. A premium carefully art-directed flat circuit-board composition viewed straight down, no perspective distortion. Upper third must be quiet dark olive board with sparse traces for bright readable keyboard toolbar text; components arranged mainly along outer edges and lower half, center has understated organized traces. Soft controlled studio lighting, beautiful precise material detail, natural subdued greens, clean tactile craftsmanship, no neon sci-fi lighting. Board fills image edge to edge. No outer device shell, screen, controls, keys, letters, numbers, logos, watermark, UI, text labels. Highest available fidelity, original wallpaper only.

## gbc 最終生成プロンプト

Use case: product-mockup. Asset type: high-resolution 4:3 wallpaper background for a production mobile keyboard. Original exquisite straight-down macro product photograph of vintage handheld-game electronics visible THROUGH a translucent atomic violet plastic case, inspired by the transparent purple Game Boy Color era. Deep violet and lavender transparent resin over a rich purple-tinted PCB, visible fine traces, black microchips, tiny capacitors, subtle silver solder points, delicate molded ribs near the edges. It must convincingly look like transparent violet plastic with internal hardware beneath, with restrained soft reflections and gentle depth, not an opaque purple circuit illustration. Upper third is quiet very dark violet with sparse components for white toolbar labels; components cluster at outer edges and lower area. Premium studio product lighting, sophisticated luminous violet, high-detail clean polished tactile surfaces, edge-to-edge composition, no perspective tilt. No device silhouette, screen, buttons, keys, text, numbers, branding, logos, UI or watermark. Highest available fidelity. Wallpaper only, no keyboard mockup.

## sfc 最終生成プロンプト

Use case: product-mockup. Asset type: high-resolution 4:3 wallpaper background for a production mobile keyboard. Original premium straight-down macro photograph of a vintage early-1990s Japanese 16-bit game console circuit board inspired by Super Famicom internal hardware, not exact reproduction. Muted deep forest-green PCB with precise copper traces, neatly placed charcoal integrated circuits, silver solder and pale-grey components. A few small hardware details subtly accented with classic red, yellow, blue, green, no decorative confetti. Refined pale-grey console era aesthetic expressed through components, mature organized engineering composition. Upper third quiet dark forest green with sparse traces for readable white toolbar text; component clusters at edges and lower area, center kept simple behind translucent keys. Soft high-end product photography, rich material detail, controlled highlights, edge-to-edge board composition, no perspective tilt. No console silhouette, controllers, keyboard keys, screen, logos, letters, numbers, UI, text or watermark. Highest available fidelity. Wallpaper only.
