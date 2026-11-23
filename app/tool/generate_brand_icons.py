#!/usr/bin/env python3
"""Generates the جَرّتي launcher icons and splash logos from code.

The brand is an apricot squircle with a cream gas cylinder, matching the
in-app BrandMark and the landing page palette.

Usage: python3 tool/generate_brand_icons.py
Requires Pillow (pip install Pillow).
"""

from functools import lru_cache
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
SS = 4  # Supersampling factor, downscaled with Lanczos at the end.

APRICOT_TOP = (250, 194, 137, 255)
APRICOT_BOTTOM = (224, 130, 55, 255)
CREAM = (255, 248, 239, 255)
CREAM_SHADE = (243, 212, 174, 255)
NAVY = (51, 71, 95, 255)
WHITE = (255, 255, 255, 255)


def _gradient(size: int) -> Image.Image:
    """Vertical apricot gradient with a soft light in the top-right corner."""
    strip = Image.new("RGBA", (1, size))
    for y in range(size):
        t = y / max(size - 1, 1)
        strip.putpixel(
            (0, y),
            tuple(round(a + (b - a) * t) for a, b in zip(APRICOT_TOP, APRICOT_BOTTOM)),
        )
    image = strip.resize((size, size), Image.NEAREST)

    glow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse(
        (size * 0.35, -size * 0.45, size * 1.45, size * 0.75),
        fill=(255, 255, 255, 70),
    )
    glow = glow.filter(ImageFilter.GaussianBlur(size * 0.18))
    return Image.alpha_composite(image, glow)


def _cylinder(size: int, scale: float = 1.0, body_color=CREAM, valve_color=NAVY):
    """Draws the gas-cylinder glyph centred in a transparent square."""
    layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)

    cx, cy = size / 2, size / 2
    s = (size / 1024) * scale

    def point(x, y):
        return (cx + (x - 512) * s, cy + (y - 480) * s)

    def box(x0, y0, x1, y1):
        return (*point(x0, y0), *point(x1, y1))

    body = box(350, 330, 674, 820)
    neck = box(458, 258, 566, 360)
    body_radius = 88 * s
    neck_radius = 30 * s

    # Soft shadow under the cylinder.
    shadow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).ellipse(box(372, 796, 652, 878), fill=(90, 45, 10, 85))
    layer = Image.alpha_composite(
        layer, shadow.filter(ImageFilter.GaussianBlur(28 * s))
    )

    # Body plus neck, with the shading clipped to their silhouette.
    metal = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    metal_draw = ImageDraw.Draw(metal)
    metal_draw.rounded_rectangle(body, radius=body_radius, fill=body_color)
    metal_draw.rounded_rectangle(neck, radius=neck_radius, fill=body_color)
    metal_draw.rounded_rectangle(box(362, 792, 658, 844), radius=20 * s,
                                 fill=CREAM_SHADE)
    metal_draw.rounded_rectangle(box(350, 604, 674, 654), radius=16 * s,
                                 fill=CREAM_SHADE)

    # Volume: a horizontal light-to-shade sweep, clipped to the silhouette.
    strip = Image.new("RGBA", (size, 1), (0, 0, 0, 0))
    body_left, body_right = body[0], body[2]
    stops = [
        (0.00, (255, 255, 255, 0)),
        (0.10, (255, 255, 255, 120)),
        (0.32, (255, 255, 255, 40)),
        (0.58, (255, 255, 255, 0)),
        (0.86, (222, 180, 136, 40)),
        (1.00, (206, 158, 112, 110)),
    ]
    for x in range(size):
        if x < body_left or x > body_right:
            continue
        t = (x - body_left) / max(body_right - body_left, 1)
        for (t0, c0), (t1, c1) in zip(stops, stops[1:]):
            if t0 <= t <= t1:
                f = (t - t0) / max(t1 - t0, 1e-6)
                strip.putpixel(
                    (x, 0),
                    tuple(round(a + (b - a) * f) for a, b in zip(c0, c1)),
                )
                break
    volume = strip.resize((size, size), Image.NEAREST)
    metal = Image.alpha_composite(metal, volume)

    silhouette = Image.new("L", (size, size), 0)
    silhouette_draw = ImageDraw.Draw(silhouette)
    silhouette_draw.rounded_rectangle(body, radius=body_radius, fill=255)
    silhouette_draw.rounded_rectangle(neck, radius=neck_radius, fill=255)
    silhouette_draw.rounded_rectangle(box(362, 792, 658, 844), radius=20 * s,
                                      fill=255)
    metal.putalpha(ImageChops.multiply(metal.getchannel("A"), silhouette))
    layer = Image.alpha_composite(layer, metal)

    # Valve stem and handwheel.
    draw = ImageDraw.Draw(layer)
    draw.rounded_rectangle(box(490, 196, 534, 288), radius=12 * s, fill=valve_color)
    draw.rounded_rectangle(box(436, 148, 588, 206), radius=28 * s, fill=valve_color)
    draw.rounded_rectangle(box(494, 164, 530, 192), radius=10 * s,
                           fill=body_color)
    return layer


def _mask(size: int, radius: int | None = None) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    if radius is None:
        draw.ellipse((0, 0, size, size), fill=255)
    else:
        draw.rounded_rectangle((0, 0, size, size), radius=radius, fill=255)
    return mask


@lru_cache(maxsize=None)
def _glyph(scale: float) -> Image.Image:
    return _cylinder(1024 * SS, scale)


@lru_cache(maxsize=None)
def _background() -> Image.Image:
    return _gradient(1024 * SS)


def render(size: int, *, tile: bool = False, glyph_only: bool = False,
           rounded: bool = False) -> Image.Image:
    canvas_size = 1024 * SS
    if glyph_only:
        canvas = _glyph(0.78).copy()
    elif tile:
        canvas = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
        inset = int(canvas_size * 0.14)
        tile_image = _background().copy()
        tile_mask = Image.new("L", (canvas_size, canvas_size), 0)
        ImageDraw.Draw(tile_mask).rounded_rectangle(
            (inset, inset, canvas_size - inset, canvas_size - inset),
            radius=int(canvas_size * 0.24),
            fill=255,
        )
        tile_image.putalpha(tile_mask)
        canvas = Image.alpha_composite(canvas, tile_image)
        canvas = Image.alpha_composite(canvas, _glyph(0.72))
    else:
        canvas = _background().copy()
        canvas = Image.alpha_composite(canvas, _glyph(1.0))
        if rounded:
            mask = Image.new("L", (canvas_size, canvas_size), 0)
            ImageDraw.Draw(mask).rounded_rectangle(
                (0, 0, canvas_size, canvas_size),
                radius=int(canvas_size * 0.22),
                fill=255,
            )
            canvas.putalpha(mask)

    return canvas.resize((size, size), Image.LANCZOS)


def save(image: Image.Image, path: Path, *, rounded: bool = False,
         circular: bool = False, opaque: bool = False) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if rounded or circular:
        mask = _mask(image.width, None if circular else int(image.width * 0.22))
        image.putalpha(mask)
    if opaque:
        flat = Image.new("RGB", image.size, (255, 255, 255))
        flat.paste(image, mask=image.getchannel("A"))
        image = flat
    image.save(path, "PNG", optimize=True)
    print(f"  {path.relative_to(ROOT)}  ({image.width}x{image.height})")


def main() -> None:
    res = ROOT / "android/app/src/main/res"
    legacy = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
    adaptive = {"mdpi": 108, "hdpi": 162, "xhdpi": 216, "xxhdpi": 324, "xxxhdpi": 432}
    splash = {"mdpi": 128, "hdpi": 192, "xhdpi": 256, "xxhdpi": 384, "xxxhdpi": 512}

    print("Android launcher icons")
    for density, size in legacy.items():
        icon = render(size, rounded=True)
        save(icon, res / f"mipmap-{density}/ic_launcher.png")
        save(icon, res / f"mipmap-{density}/ic_launcher_round.png", circular=True)

    print("Android adaptive foreground")
    for density, size in adaptive.items():
        save(render(size, glyph_only=True),
             res / f"mipmap-{density}/ic_launcher_foreground.png")

    print("Android splash logos")
    for density, size in splash.items():
        save(render(size, tile=True), res / f"drawable-{density}/launch_logo.png")

    print("iOS app icons")
    icons = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    for path in sorted(icons.glob("Icon-App-*.png")):
        stem = path.stem.split("-")[-1]  # e.g. 1024x1024@1x
        spec, scale = stem.split("@")
        points = int(round(float(spec.split("x")[0]) * int(scale.rstrip("x"))))
        save(render(points), path, opaque=True)

    print("iOS launch images")
    launch = ROOT / "ios/Runner/Assets.xcassets/LaunchImage.imageset"
    save(render(140, tile=True), launch / "LaunchImage.png")
    save(render(280, tile=True), launch / "LaunchImage@2x.png")
    save(render(420, tile=True), launch / "LaunchImage@3x.png")


if __name__ == "__main__":
    main()
