# XP / Vista 背景素材

2026-10-09、imagegenスキルのbuilt-in image_genで新規生成。各1448×1086pxのPNG。画像のリサイズや加工を行わず、Asset Catalogに原寸で同梱する。

- [XP素材](../DesignSystem/Assets.xcassets/DesktopXP.imageset/wallpaper.png): オリジナルの空・丘の風景。
- [Vista素材](../DesignSystem/Assets.xcassets/DesktopVista.imageset/wallpaper.png): オリジナルの青緑の光と透明な層。
- 本体/拡張/StorageTestsが同じAsset Catalogを使用。高品質補間とaspect fillで表示。キーと文字はネイティブUIとして重ねる。
- キーボード幅390ptの3倍解像度1170pxを覆う素材。より大きい表示幅では拡大される。

## XP 最終生成プロンプト

Use case: photorealistic-natural. Asset type: production iPhone keyboard background wallpaper, landscape 4:3 composition, highest available resolution and visual fidelity. Create an original premium desktop-nostalgia landscape inspired by Windows XP: an exquisitely smooth rolling emerald grassy hill under a luminous rich azure blue sky with sparse soft white cumulus clouds. Professional landscape photography, lush natural fine grass texture, natural soft sunlight, sophisticated restrained color grading, serene timeless optimism. Composition: sky fills upper 62%, clean quiet deep azure upper third for readable white toolbar text, hill crest sweeping gently from left at 62% down to right at 72%; mostly simple green lower field behind cream keyboard buttons. Smooth clean full-resolution detail, no pixelation, no dithering. No mountains, buildings, people, trees, flowers, logos, text, keyboard, UI or watermark. This is a background asset, not a product screenshot. Original landscape rather than exact reproduction of an existing wallpaper.

## Vista 最終生成プロンプト

Use case: stylized-concept. Asset type: production iPhone keyboard background wallpaper, landscape 4:3 composition, highest available resolution and visual fidelity. Create an original exquisite abstract premium desktop wallpaper inspired by the luminous Windows Vista Aero era. Deep midnight petrol blue and dark teal atmosphere with a small number of graceful flowing aurora-like translucent light ribbons: luminous emerald, jade, pale cyan. Smooth rich gradients, convincing optical translucency, subtle broad glow, elegant layered sweeping curves from lower left towards upper right. Professional product art direction, luxurious and restrained. Upper third must remain calm uniform very dark blue-teal as a safe area for white toolbar labels; visual movement mostly across middle and lower right. Refined high-resolution detail, absolutely smooth curves and gradients, no pixelation, banding, noisy grain, star fields, excessive streaks or lens flare. No logos, Windows logo, text, UI, keys, keyboard or watermark. A wallpaper asset only, not a screenshot. Render with subtle depth and a gentle suggestion of polished glass.
