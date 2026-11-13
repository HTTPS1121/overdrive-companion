#!/usr/bin/env python3
"""Build labelled 390×844 side-by-sides: Demo (HTML) | App (Flutter)."""
from __future__ import annotations

import os
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(os.environ.get("OD_ARTIFACT_ROOT", "/cursor/stores/self/artifacts/rebuild-v1/final"))
NAMES = [
    "01_login",
    "02_home",
    "03_camera",
    "04_recordings",
    "05_trip",
    "06_more",
    "07_confirm_lock",
    "08_profile",
    "09_menu",
]
W, H = 390, 844
LABEL_H = 28
GAP = 8
PAD = 12


def load_font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    try:
        return ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", size)
    except OSError:
        return ImageFont.load_default()


def fit(im: Image.Image) -> Image.Image:
    im = im.convert("RGB")
    if im.size == (W, H):
        return im
    return im.resize((W, H), Image.Resampling.LANCZOS)


def main() -> None:
    html_dir = ROOT / "html"
    flutter_dir = ROOT / "flutter"
    out_dir = ROOT / "compare"
    out_dir.mkdir(parents=True, exist_ok=True)
    font = load_font(16)
    for name in NAMES:
        demo = fit(Image.open(html_dir / f"{name}.png"))
        app = fit(Image.open(flutter_dir / f"{name}.png"))
        canvas_w = W * 2 + GAP + PAD * 2
        canvas_h = H + LABEL_H + PAD * 2
        out = Image.new("RGB", (canvas_w, canvas_h), (248, 250, 252))
        draw = ImageDraw.Draw(out)
        x_demo = PAD
        x_app = PAD + W + GAP
        y_img = PAD + LABEL_H
        out.paste(demo, (x_demo, y_img))
        out.paste(app, (x_app, y_img))
        draw.text((x_demo + 8, PAD + 4), "Demo", fill=(33, 47, 80), font=font)
        draw.text((x_app + 8, PAD + 4), "App", fill=(33, 47, 80), font=font)
        out.save(out_dir / f"{name}_side_by_side.png")
    print("Wrote", len(NAMES), "comparisons to", out_dir)


if __name__ == "__main__":
    main()
