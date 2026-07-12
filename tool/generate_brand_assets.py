"""Generate Life Spark logo, splash, and gradient app-icon assets from source PNG."""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image

SRC = Path(
    r"C:\Users\Federick Vidot\.cursor\projects\c-Users-Federick-Vidot-MTG-Life-Spark"
    r"\assets\c__Users_Federick_Vidot_AppData_Roaming_Cursor_User_workspaceStorage_"
    r"empty-window_images_LifeSpark_1024x1024-b192ef00-398c-4b93-a3fc-e4bebc7a9b99.png"
)
OUT = Path(__file__).resolve().parents[1] / "assets" / "images"
WEB = Path(__file__).resolve().parents[1] / "web"
WEB_ICONS = WEB / "icons"


def white_on_transparent(img: Image.Image) -> Image.Image:
    img = img.convert("RGBA")
    pixels = img.load()
    w, h = img.size
    for y in range(h):
        for x in range(w):
            r, g, b, _a = pixels[x, y]
            lum = (r + g + b) / 3
            if lum < 40:
                pixels[x, y] = (0, 0, 0, 0)
            else:
                alpha = int(min(255, max(0, (lum - 40) * 255 / 80)))
                pixels[x, y] = (255, 255, 255, alpha)
    bbox = img.getbbox()
    logo = img.crop(bbox)
    side = max(logo.size)
    pad = int(side * 0.12)
    canvas_size = side + pad * 2
    square = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    ox = (canvas_size - logo.size[0]) // 2
    oy = (canvas_size - logo.size[1]) // 2
    square.paste(logo, (ox, oy), logo)
    return square


def make_gradient(size: int) -> Image.Image:
    grad = Image.new("RGBA", (size, size))
    px = grad.load()
    c0 = (18, 18, 26)
    c1 = (42, 31, 69)
    c2 = (155, 109, 255)
    for y in range(size):
        t = y / (size - 1)
        if t < 0.55:
            u = t / 0.55
            r = int(c0[0] + (c1[0] - c0[0]) * u)
            g = int(c0[1] + (c1[1] - c0[1]) * u)
            b = int(c0[2] + (c1[2] - c0[2]) * u)
        else:
            u = (t - 0.55) / 0.45
            r = int(c1[0] + (c2[0] - c1[0]) * u)
            g = int(c1[1] + (c2[1] - c1[1]) * u)
            b = int(c1[2] + (c2[2] - c1[2]) * u)
        for x in range(size):
            dx = (x - size / 2) / (size / 2)
            dy = (y - size / 2) / (size / 2)
            rad = math.sqrt(dx * dx + dy * dy)
            boost = max(0.0, 1.0 - rad) * 0.15
            px[x, y] = (
                min(255, int(r + (c2[0] - r) * boost)),
                min(255, int(g + (c2[1] - g) * boost)),
                min(255, int(b + (c2[2] - b) * boost)),
                255,
            )
    return grad


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    WEB_ICONS.mkdir(parents=True, exist_ok=True)

    square = white_on_transparent(Image.open(SRC))
    master = square.resize((1024, 1024), Image.Resampling.LANCZOS)
    master.save(OUT / "life_spark_logo.png")
    master.save(OUT / "splash_logo.png")

    fg = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
    mark = square.resize((int(1024 * 0.62), int(1024 * 0.62)), Image.Resampling.LANCZOS)
    fg.paste(mark, ((1024 - mark.size[0]) // 2, (1024 - mark.size[1]) // 2), mark)
    fg.save(OUT / "app_icon_fg.png")

    icon = make_gradient(1024)
    mark2 = square.resize((int(1024 * 0.68), int(1024 * 0.68)), Image.Resampling.LANCZOS)
    icon.paste(mark2, ((1024 - mark2.size[0]) // 2, (1024 - mark2.size[1]) // 2), mark2)
    icon.save(OUT / "app_icon.png")

    icon.resize((32, 32), Image.Resampling.LANCZOS).save(WEB / "favicon.png")
    icon.resize((192, 192), Image.Resampling.LANCZOS).save(WEB_ICONS / "Icon-192.png")
    icon.resize((512, 512), Image.Resampling.LANCZOS).save(WEB_ICONS / "Icon-512.png")
    square.resize((256, 256), Image.Resampling.LANCZOS).save(
        WEB_ICONS / "life_spark_logo.png"
    )
    print("Brand assets generated.")


if __name__ == "__main__":
    main()
