import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

private func fail(_ message: String) -> Never {
  FileHandle.standardError.write(Data("\(message)\n".utf8))
  exit(1)
}

guard CommandLine.arguments.count == 3 else {
  fail("Usage: swift tool/process_mascot_sheet.swift <sheet.png> <output-directory>")
}

let inputURL = URL(fileURLWithPath: CommandLine.arguments[1])
let outputDirectory = URL(fileURLWithPath: CommandLine.arguments[2])
let poseNames = [
  "idle",
  "welcome",
  "thinking",
  "celebrating",
  "oops",
  "encouraging",
  "winner",
]

guard
  let source = CGImageSourceCreateWithURL(inputURL as CFURL, nil),
  let sheet = CGImageSourceCreateImageAtIndex(source, 0, nil)
else {
  fail("Could not decode \(inputURL.path)")
}

let columns = 4
let rows = 2
guard sheet.width % columns == 0, sheet.height % rows == 0 else {
  fail("The pose sheet must be an exact 4x2 grid")
}

let cellWidth = sheet.width / columns
let cellHeight = sheet.height / rows
try FileManager.default.createDirectory(
  at: outputDirectory,
  withIntermediateDirectories: true
)

guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
  fail("Could not create the sRGB color space")
}

let bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue |
  CGImageAlphaInfo.premultipliedLast.rawValue

for (index, name) in poseNames.enumerated() {
  let column = index % columns
  let row = index / columns
  let cropRect = CGRect(
    x: column * cellWidth,
    y: row * cellHeight,
    width: cellWidth,
    height: cellHeight
  )

  guard let cropped = sheet.cropping(to: cropRect) else {
    fail("Could not crop pose \(name)")
  }

  let bytesPerRow = cellWidth * 4
  var pixels = [UInt8](repeating: 0, count: cellHeight * bytesPerRow)
  guard let context = CGContext(
    data: &pixels,
    width: cellWidth,
    height: cellHeight,
    bitsPerComponent: 8,
    bytesPerRow: bytesPerRow,
    space: colorSpace,
    bitmapInfo: bitmapInfo
  ) else {
    fail("Could not create the bitmap context for \(name)")
  }

  context.clear(CGRect(x: 0, y: 0, width: cellWidth, height: cellHeight))
  context.draw(
    cropped,
    in: CGRect(x: 0, y: 0, width: cellWidth, height: cellHeight)
  )

  for pixelIndex in 0..<(cellWidth * cellHeight) {
    let offset = pixelIndex * 4
    let red = Double(pixels[offset])
    let green = Double(pixels[offset + 1])
    let blue = Double(pixels[offset + 2])
    let alpha = Double(pixels[offset + 3])

    // The source sheet deliberately uses a saturated blue studio backdrop.
    // Key only blue-dominant pixels so the navy face and emerald highlights
    // remain intact, while the soft transition preserves antialiased edges.
    let dominance = blue - max(red, green)
    let blueGate = max(0, min(1, (blue - 85) / 120))
    let dominanceGate = max(0, min(1, (dominance - 24) / 100))
    let keep = 1 - (blueGate * dominanceGate)

    pixels[offset] = UInt8(red * keep)
    pixels[offset + 1] = UInt8(green * keep)
    pixels[offset + 2] = UInt8(blue * keep)
    pixels[offset + 3] = UInt8(alpha * keep)
  }

  guard let outputImage = context.makeImage() else {
    fail("Could not create the processed image for \(name)")
  }

  let outputURL = outputDirectory.appendingPathComponent("sila_\(name).png")
  guard let destination = CGImageDestinationCreateWithURL(
    outputURL as CFURL,
    UTType.png.identifier as CFString,
    1,
    nil
  ) else {
    fail("Could not create \(outputURL.path)")
  }

  CGImageDestinationAddImage(destination, outputImage, nil)
  guard CGImageDestinationFinalize(destination) else {
    fail("Could not write \(outputURL.path)")
  }

  print("Wrote \(outputURL.lastPathComponent) (\(cellWidth)x\(cellHeight), RGBA)")
}
