"""Extract transparent H/V Life Spark wordmark logos into assets/images."""

from __future__ import annotations

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "images"
CURSOR_ASSETS = Path(
    r"C:\Users\Federick Vidot\.cursor\projects\c-Users-Federick-Vidot-MTG-Life-Spark\assets"
)

VERTICAL_SRC = next(CURSOR_ASSETS.glob("*Vertical_Logo*.png"))
HORIZONTAL_SRC = next(CURSOR_ASSETS.glob("*Horizontal_Logo*.png"))


def to_white_transparent(img: Image.Image, scale: int = 8) -> Image.Image:
    img = img.convert("RGBA")
    pixels = img.load()
    w, h = img.size
    for y in range(h):
        for x in range(w):
            r, g, b, _a = pixels[x, y]
            lum = (r + g + b) / 3.0
            if lum < 40:
                pixels[x, y] = (0, 0, 0, 0)
            else:
                alpha = int(min(255, max(0, (lum - 40) * 255 / 80)))
                pixels[x, y] = (255, 255, 255, alpha)
    bbox = img.getbbox()
    cropped = img.crop(bbox)
    # Upscale for crisp UI use
    big = cropped.resize(
        (cropped.size[0] * scale, cropped.size[1] * scale),
        Image.Resampling.LANCZOS,
    )
    return big


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    vert = to_white_transparent(Image.open(VERTICAL_SRC), scale=10)
    horiz = to_white_transparent(Image.open(HORIZONTAL_SRC), scale=8)
    vert.save(OUT / "logo_vertical.png")
    horiz.save(OUT / "logo_horizontal.png")
    print("wrote", OUT / "logo_vertical.png", vert.size)
    print("wrote", OUT / "logo_horizontal.png", horiz.size)


if __name__ == "__main__":
    main()
