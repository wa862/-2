const fs = require('fs')
const path = require('path')
const zlib = require('zlib')

const outDir = path.resolve(__dirname, '../src/static/tab')
const size = 81
const icons = ['home', 'service', 'mall', 'cart', 'profile']
const colors = {
  normal: [144, 147, 153, 255],
  active: [64, 158, 255, 255],
}

function crc32(buf) {
  let c = ~0
  for (let i = 0; i < buf.length; i++) {
    c ^= buf[i]
    for (let k = 0; k < 8; k++) c = (c >>> 1) ^ (0xedb88320 & -(c & 1))
  }
  return ~c >>> 0
}

function chunk(type, data) {
  const name = Buffer.from(type)
  const len = Buffer.alloc(4)
  const crc = Buffer.alloc(4)
  len.writeUInt32BE(data.length)
  crc.writeUInt32BE(crc32(Buffer.concat([name, data])))
  return Buffer.concat([len, name, data, crc])
}

function pngFromRgba(rgba, width, height) {
  const scanlines = Buffer.alloc((width * 4 + 1) * height)
  for (let y = 0; y < height; y++) {
    const row = y * (width * 4 + 1)
    scanlines[row] = 0
    rgba.copy(scanlines, row + 1, y * width * 4, (y + 1) * width * 4)
  }
  const ihdr = Buffer.alloc(13)
  ihdr.writeUInt32BE(width, 0)
  ihdr.writeUInt32BE(height, 4)
  ihdr[8] = 8
  ihdr[9] = 6
  return Buffer.concat([
    Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
    chunk('IHDR', ihdr),
    chunk('IDAT', zlib.deflateSync(scanlines, { level: 9 })),
    chunk('IEND', Buffer.alloc(0)),
  ])
}

function createCanvas(color) {
  const data = Buffer.alloc(size * size * 4)
  const set = (x, y, a = 1) => {
    if (x < 0 || y < 0 || x >= size || y >= size) return
    const i = (Math.round(y) * size + Math.round(x)) * 4
    data[i] = color[0]
    data[i + 1] = color[1]
    data[i + 2] = color[2]
    data[i + 3] = Math.max(data[i + 3], Math.round(color[3] * a))
  }
  return { data, set }
}

function line(c, x1, y1, x2, y2, w = 5) {
  const dx = x2 - x1
  const dy = y2 - y1
  const steps = Math.max(Math.abs(dx), Math.abs(dy)) * 2
  for (let i = 0; i <= steps; i++) {
    const t = i / steps
    dot(c, x1 + dx * t, y1 + dy * t, w)
  }
}

function dot(c, cx, cy, r) {
  for (let y = Math.floor(cy - r); y <= Math.ceil(cy + r); y++) {
    for (let x = Math.floor(cx - r); x <= Math.ceil(cx + r); x++) {
      const d = Math.hypot(x - cx, y - cy)
      if (d <= r) c.set(x, y, 1)
    }
  }
}

function rect(c, x, y, w, h, r = 4, stroke = 5) {
  line(c, x + r, y, x + w - r, y, stroke)
  line(c, x + r, y + h, x + w - r, y + h, stroke)
  line(c, x, y + r, x, y + h - r, stroke)
  line(c, x + w, y + r, x + w, y + h - r, stroke)
  dot(c, x + r, y + r, stroke)
  dot(c, x + w - r, y + r, stroke)
  dot(c, x + r, y + h - r, stroke)
  dot(c, x + w - r, y + h - r, stroke)
}

function arc(c, cx, cy, r, start, end, w = 5) {
  for (let a = start; a <= end; a += 0.012) {
    dot(c, cx + Math.cos(a) * r, cy + Math.sin(a) * r, w)
  }
}

function draw(name, color) {
  const c = createCanvas(color)
  if (name === 'home') {
    line(c, 16, 38, 41, 17, 66, 38, 5)
    rect(c, 24, 36, 34, 28, 3, 5)
    line(c, 40, 64, 40, 50, 5)
  } else if (name === 'service') {
    rect(c, 22, 24, 37, 40, 7, 5)
    arc(c, 40.5, 24, 11, Math.PI, Math.PI * 2, 4)
    line(c, 30, 41, 51, 41, 4)
    line(c, 30, 52, 47, 52, 4)
  } else if (name === 'mall') {
    rect(c, 20, 28, 41, 34, 6, 5)
    arc(c, 40.5, 31, 12, Math.PI, Math.PI * 2, 4)
    line(c, 20, 39, 61, 39, 4)
  } else if (name === 'cart') {
    line(c, 15, 23, 24, 23, 5)
    line(c, 24, 23, 31, 54, 5)
    line(c, 31, 54, 59, 54, 5)
    line(c, 29, 34, 63, 34, 5)
    line(c, 63, 34, 58, 49, 5)
    dot(c, 34, 64, 5)
    dot(c, 56, 64, 5)
  } else if (name === 'profile') {
    dot(c, 41, 29, 12)
    arc(c, 41, 69, 24, Math.PI * 1.12, Math.PI * 1.88, 6)
  }
  return pngFromRgba(c.data, size, size)
}

fs.mkdirSync(outDir, { recursive: true })
for (const icon of icons) {
  fs.writeFileSync(path.join(outDir, `${icon}.png`), draw(icon, colors.normal))
  fs.writeFileSync(path.join(outDir, `${icon}-active.png`), draw(icon, colors.active))
}
