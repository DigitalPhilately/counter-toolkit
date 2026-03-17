import AppKit
import Foundation

extension NSColor {
  convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
    let red = CGFloat((hex >> 16) & 0xFF) / 255.0
    let green = CGFloat((hex >> 8) & 0xFF) / 255.0
    let blue = CGFloat(hex & 0xFF) / 255.0
    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
}

func roundedRect(_ rect: NSRect, radius: CGFloat) -> NSBezierPath {
  NSBezierPath(
    roundedRect: rect,
    xRadius: radius,
    yRadius: radius
  )
}

func fillRoundedRect(_ rect: NSRect, radius: CGFloat, color: NSColor) {
  color.setFill()
  roundedRect(rect, radius: radius).fill()
}

func strokeRoundedRect(
  _ rect: NSRect,
  radius: CGFloat,
  color: NSColor,
  width: CGFloat
) {
  color.setStroke()
  let path = roundedRect(rect, radius: radius)
  path.lineWidth = width
  path.stroke()
}

let fileManager = FileManager.default
let root = URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
let outputDir = root.appendingPathComponent("assets/app_icon", isDirectory: true)
let outputURL = outputDir.appendingPathComponent("counter_toolkit_icon_1024.png")
let iosLaunchImageDir = root.appendingPathComponent(
  "ios/Runner/Assets.xcassets/LaunchImage.imageset",
  isDirectory: true
)

try fileManager.createDirectory(
  at: outputDir,
  withIntermediateDirectories: true
)
try fileManager.createDirectory(
  at: iosLaunchImageDir,
  withIntermediateDirectories: true
)

func writePNG(_ bitmap: NSBitmapImageRep, to url: URL) throws {
  guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Unable to create PNG data for \(url.lastPathComponent)")
  }

  try pngData.write(to: url, options: .atomic)
}

func scaledBitmap(from image: NSImage, dimension: Int) -> NSBitmapImageRep {
  let size = NSSize(width: dimension, height: dimension)
  guard let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: dimension,
    pixelsHigh: dimension,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
  ),
    let context = NSGraphicsContext(bitmapImageRep: bitmap)
  else {
    fatalError("Unable to create scaled bitmap context")
  }

  bitmap.size = size

  NSGraphicsContext.saveGraphicsState()
  NSGraphicsContext.current = context
  NSColor.clear.setFill()
  NSRect(origin: .zero, size: size).fill()
  image.draw(
    in: NSRect(origin: .zero, size: size),
    from: NSRect(origin: .zero, size: image.size),
    operation: .copy,
    fraction: 1.0
  )
  NSGraphicsContext.restoreGraphicsState()

  return bitmap
}

let canvasSize = NSSize(width: 1024, height: 1024)
guard let bitmap = NSBitmapImageRep(
  bitmapDataPlanes: nil,
  pixelsWide: Int(canvasSize.width),
  pixelsHigh: Int(canvasSize.height),
  bitsPerSample: 8,
  samplesPerPixel: 4,
  hasAlpha: true,
  isPlanar: false,
  colorSpaceName: .deviceRGB,
  bytesPerRow: 0,
  bitsPerPixel: 0
),
  let context = NSGraphicsContext(bitmapImageRep: bitmap)
else {
  fatalError("Unable to create bitmap context")
}

bitmap.size = canvasSize
let canvas = NSRect(origin: .zero, size: canvasSize)

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = context

let backgroundPath = roundedRect(canvas, radius: 220)
let backgroundGradient = NSGradient(
  colors: [
    NSColor(hex: 0x123B39),
    NSColor(hex: 0x1A5D58),
  ]
)!
backgroundGradient.draw(in: backgroundPath, angle: -55)

NSColor.white.withAlphaComponent(0.10).setFill()
NSBezierPath(ovalIn: NSRect(x: -40, y: 660, width: 560, height: 320)).fill()

let rulerShadow = NSShadow()
rulerShadow.shadowBlurRadius = 28
rulerShadow.shadowOffset = NSSize(width: 0, height: -12)
rulerShadow.shadowColor = NSColor.black.withAlphaComponent(0.16)
rulerShadow.set()

let rulerRect = NSRect(x: 692, y: 252, width: 108, height: 486)
fillRoundedRect(rulerRect, radius: 42, color: NSColor(hex: 0xF6EFE4))
strokeRoundedRect(
  rulerRect,
  radius: 42,
  color: NSColor(hex: 0xCDBBA0, alpha: 0.75),
  width: 8
)

NSGraphicsContext.restoreGraphicsState()
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = context

let parcelShadow = NSShadow()
parcelShadow.shadowBlurRadius = 42
parcelShadow.shadowOffset = NSSize(width: 0, height: -18)
parcelShadow.shadowColor = NSColor.black.withAlphaComponent(0.18)
parcelShadow.set()

let parcelFront = NSRect(x: 264, y: 314, width: 430, height: 360)
fillRoundedRect(parcelFront, radius: 54, color: NSColor(hex: 0xC88943))
strokeRoundedRect(
  parcelFront,
  radius: 54,
  color: NSColor(hex: 0x8F5F29, alpha: 0.50),
  width: 10
)

NSGraphicsContext.restoreGraphicsState()
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = context

let lid = NSBezierPath()
lid.move(to: NSPoint(x: 264, y: 674))
lid.line(to: NSPoint(x: 378, y: 764))
lid.line(to: NSPoint(x: 760, y: 764))
lid.line(to: NSPoint(x: 694, y: 674))
lid.close()
NSColor(hex: 0xD79E58).setFill()
lid.fill()

NSColor(hex: 0xA46D2E, alpha: 0.55).setStroke()
lid.lineWidth = 10
lid.stroke()

let seam = NSBezierPath()
seam.move(to: NSPoint(x: 478, y: 314))
seam.line(to: NSPoint(x: 478, y: 674))
seam.move(to: NSPoint(x: 470, y: 674))
seam.line(to: NSPoint(x: 470, y: 764))
seam.lineWidth = 12
seam.lineCapStyle = .round
NSColor(hex: 0x8F5F29, alpha: 0.55).setStroke()
seam.stroke()

let labelRect = NSRect(x: 356, y: 430, width: 246, height: 86)
fillRoundedRect(labelRect, radius: 20, color: NSColor(hex: 0xF8F3EA))
strokeRoundedRect(
  labelRect,
  radius: 20,
  color: NSColor(hex: 0xD4C1A4, alpha: 0.75),
  width: 6
)

let labelLineColor = NSColor(hex: 0x1E4B48, alpha: 0.85)
for offset in stride(from: 0, through: 2, by: 1) {
  let bar = roundedRect(
    NSRect(x: 390, y: 454 - CGFloat(offset) * 18, width: 178, height: 10),
    radius: 5
  )
  labelLineColor.setFill()
  bar.fill()
}

let counterRect = NSRect(x: 138, y: 104, width: 748, height: 176)
let counterShadow = NSShadow()
counterShadow.shadowBlurRadius = 30
counterShadow.shadowOffset = NSSize(width: 0, height: -10)
counterShadow.shadowColor = NSColor.black.withAlphaComponent(0.12)
counterShadow.set()

fillRoundedRect(counterRect, radius: 54, color: NSColor(hex: 0xF3E7D2))
strokeRoundedRect(
  counterRect,
  radius: 54,
  color: NSColor(hex: 0xD6C2A6, alpha: 0.75),
  width: 8
)

NSGraphicsContext.restoreGraphicsState()
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = context

let routeBadge = NSRect(x: 670, y: 148, width: 152, height: 152)
NSColor(hex: 0x2E8387).setFill()
NSBezierPath(ovalIn: routeBadge).fill()

let route = NSBezierPath()
route.move(to: NSPoint(x: 722, y: 222))
route.curve(
  to: NSPoint(x: 774, y: 214),
  controlPoint1: NSPoint(x: 742, y: 254),
  controlPoint2: NSPoint(x: 768, y: 242)
)
route.curve(
  to: NSPoint(x: 774, y: 182),
  controlPoint1: NSPoint(x: 780, y: 202),
  controlPoint2: NSPoint(x: 780, y: 191)
)
route.line(to: NSPoint(x: 802, y: 206))
route.move(to: NSPoint(x: 774, y: 182))
route.line(to: NSPoint(x: 806, y: 184))
route.lineWidth = 15
route.lineCapStyle = .round
route.lineJoinStyle = .round
NSColor.white.setStroke()
route.stroke()

for index in 0..<6 {
  let width: CGFloat = index.isMultiple(of: 2) ? 38 : 22
  let tick = NSBezierPath()
  let y = 662 - CGFloat(index) * 58
  tick.move(to: NSPoint(x: 736, y: y))
  tick.line(to: NSPoint(x: 736 + width, y: y))
  tick.lineWidth = 9
  tick.lineCapStyle = .round
  NSColor(hex: 0x1B5552, alpha: 0.88).setStroke()
  tick.stroke()
}

let dot = NSBezierPath(ovalIn: NSRect(x: 704, y: 626, width: 22, height: 22))
NSColor(hex: 0x1B5552, alpha: 0.88).setFill()
dot.fill()

NSGraphicsContext.restoreGraphicsState()

try writePNG(bitmap, to: outputURL)

let iconImage = NSImage(size: canvasSize)
iconImage.addRepresentation(bitmap)

let launchImages: [(String, Int)] = [
  ("LaunchImage.png", 220),
  ("LaunchImage@2x.png", 440),
  ("LaunchImage@3x.png", 660),
]

for (filename, dimension) in launchImages {
  let scaled = scaledBitmap(from: iconImage, dimension: dimension)
  let url = iosLaunchImageDir.appendingPathComponent(filename)
  try writePNG(scaled, to: url)
  print("Generated \(url.path)")
}

print("Generated \(outputURL.path)")
