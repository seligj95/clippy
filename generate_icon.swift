#!/usr/bin/env swift

import AppKit
import Foundation

// Generate a clipboard icon at multiple sizes for .iconset
let sizes: [(name: String, size: Int)] = [
    ("icon_16x16", 16),
    ("icon_16x16@2x", 32),
    ("icon_32x32", 32),
    ("icon_32x32@2x", 64),
    ("icon_128x128", 128),
    ("icon_128x128@2x", 256),
    ("icon_256x256", 256),
    ("icon_256x256@2x", 512),
    ("icon_512x512", 512),
    ("icon_512x512@2x", 1024),
]

let iconsetPath = "Clippy.iconset"
try? FileManager.default.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)

for entry in sizes {
    let s = CGFloat(entry.size)
    let image = NSImage(size: NSSize(width: s, height: s))
    image.lockFocus()

    let ctx = NSGraphicsContext.current!.cgContext

    // Background: rounded rect with gradient
    let bgRect = CGRect(x: s * 0.05, y: s * 0.05, width: s * 0.9, height: s * 0.9)
    let cornerRadius = s * 0.2
    let bgPath = CGPath(roundedRect: bgRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)

    // Gradient: blue to purple
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let gradientColors = [
        CGColor(red: 0.2, green: 0.5, blue: 1.0, alpha: 1.0),
        CGColor(red: 0.55, green: 0.3, blue: 0.95, alpha: 1.0),
    ] as CFArray
    let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors, locations: [0.0, 1.0])!

    ctx.saveGState()
    ctx.addPath(bgPath)
    ctx.clip()
    ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: s), end: CGPoint(x: s, y: 0), options: [])
    ctx.restoreGState()

    // Draw clipboard shape (white)
    ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.95))

    // Clipboard body
    let clipW = s * 0.52
    let clipH = s * 0.58
    let clipX = (s - clipW) / 2
    let clipY = s * 0.14
    let clipRadius = s * 0.06
    let clipRect = CGRect(x: clipX, y: clipY, width: clipW, height: clipH)
    let clipPath = CGPath(roundedRect: clipRect, cornerWidth: clipRadius, cornerHeight: clipRadius, transform: nil)
    ctx.addPath(clipPath)
    ctx.fillPath()

    // Clipboard clip (top part)
    let topClipW = s * 0.22
    let topClipH = s * 0.12
    let topClipX = (s - topClipW) / 2
    let topClipY = clipY + clipH - topClipH * 0.45
    let topClipRadius = s * 0.04
    let topClipRect = CGRect(x: topClipX, y: topClipY, width: topClipW, height: topClipH)
    let topClipPath = CGPath(roundedRect: topClipRect, cornerWidth: topClipRadius, cornerHeight: topClipRadius, transform: nil)
    ctx.addPath(topClipPath)
    ctx.fillPath()

    // Draw lines on clipboard (representing text)
    ctx.setStrokeColor(CGColor(red: 0.35, green: 0.5, blue: 0.9, alpha: 0.7))
    ctx.setLineWidth(max(s * 0.025, 1))
    ctx.setLineCap(.round)

    let lineX = clipX + s * 0.08
    let lineEndX = clipX + clipW - s * 0.08
    let lineSpacing = s * 0.09
    let firstLineY = clipY + s * 0.08

    for i in 0..<4 {
        let y = firstLineY + CGFloat(i) * lineSpacing
        let endX = i == 3 ? lineX + (lineEndX - lineX) * 0.6 : lineEndX
        ctx.move(to: CGPoint(x: lineX, y: y))
        ctx.addLine(to: CGPoint(x: endX, y: y))
        ctx.strokePath()
    }

    image.unlockFocus()

    // Save as PNG
    guard let tiffData = image.tiffRepresentation,
          let bitmapRep = NSBitmapImageRep(data: tiffData),
          let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
        print("Failed to create PNG for \(entry.name)")
        continue
    }

    let filePath = "\(iconsetPath)/\(entry.name).png"
    try pngData.write(to: URL(fileURLWithPath: filePath))
    print("Created \(filePath)")
}

print("Iconset created. Run: iconutil -c icns \(iconsetPath)")
