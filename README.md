# zig-dicom
Playing around with Zig ⚡ – let's see where this goes.

## Run

`zig build run`

```shell
❯ zig build run
⚡︎ Zig DICOM v0.1.0

file            samples/IM-0001-0001.dcm
size            100.904kB

╔═══════ PREAMBLE ══════╗
║  0x00(×128)           ║
║  MAGIC_WORD   yes     ║
╠═══════ ELEMENT ═══════╣
║                       ║
╟───────── TAG ─────────╢
║ group         0200    ║
║ element       0000    ║
╟─────── VR / VL ───────╢
║ VR            UL      ║
║ VL            4       ║
╟──────── VALUE ────────╢
║ value         204     ║
╚═══════════════════════╝
```
