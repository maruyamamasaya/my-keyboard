import AppKit
import ImageIO
import UniformTypeIdentifiers

// Original my-keyboard artwork. Opaque RGB square, with antialiased vector shapes.
let output = CommandLine.arguments[1]
let size = 1024
let ctx = CGContext(data:nil, width:size, height:size, bitsPerComponent:8, bytesPerRow:0,
    space:CGColorSpace(name:CGColorSpace.sRGB)!, bitmapInfo:CGImageAlphaInfo.noneSkipLast.rawValue)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(cgContext:ctx, flipped:false)
ctx.setShouldAntialias(true)
func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> NSColor {
    NSColor(srgbRed: r/255, green: g/255, blue: b/255, alpha: 1)
}
func rect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ radius: CGFloat, _ fill: NSColor) {
    fill.setFill()
    NSBezierPath(roundedRect: NSRect(x:x,y:y,width:w,height:h), xRadius:radius,yRadius:radius).fill()
}
func line(_ points: [CGPoint], _ width: CGFloat, _ fill: NSColor) {
    ctx.setStrokeColor(fill.cgColor); ctx.setLineWidth(width); ctx.setLineCap(.round); ctx.setLineJoin(.round)
    ctx.beginPath(); ctx.move(to:points[0]); for point in points.dropFirst() { ctx.addLine(to:point) }; ctx.strokePath()
}
// Blue Cosmos palette: navy #081426, keys #20364F, accent #9CD7FF.
rect(0,0,1024,1024,0,color(8,20,38))
let gradient = CGGradient(colorsSpace:CGColorSpace(name:CGColorSpace.sRGB),
    colors:[color(22,62,101).cgColor, color(8,20,38).cgColor] as CFArray, locations:[0,1])!
ctx.drawRadialGradient(gradient, startCenter:CGPoint(x:600,y:680), startRadius:0,
    endCenter:CGPoint(x:520,y:540), endRadius:650, options:[.drawsAfterEndLocation])
// A single orbital stroke and sparse stars preserve clarity at small sizes.
ctx.saveGState(); ctx.translateBy(x:512,y:544); ctx.rotate(by:0.35)
ctx.setStrokeColor(color(77,133,180).cgColor); ctx.setLineWidth(16)
ctx.strokeEllipse(in:CGRect(x:-386,y:-218,width:772,height:436)); ctx.restoreGState()
rect(185,244,654,420,64,color(156,215,255))
rect(209,268,606,372,43,color(32,54,79))
for y in [CGFloat(492),CGFloat(394)] {
    for x in [CGFloat(259),CGFloat(365),CGFloat(471),CGFloat(577),CGFloat(683)] {
        rect(x,y,82,68,17,color(242,247,255))
    }
}
rect(365,306,294,46,15,color(156,215,255))
rect(259,306,82,46,15,color(93,143,181))
rect(683,306,82,46,15,color(93,143,181))
color(156,215,255).setFill()
let star = NSBezierPath(); star.move(to:NSPoint(x:724,y:861))
for point in [NSPoint(x:740,y:817),NSPoint(x:784,y:801),NSPoint(x:740,y:785),
    NSPoint(x:724,y:741),NSPoint(x:708,y:785),NSPoint(x:664,y:801),NSPoint(x:708,y:817)] { star.line(to:point) }
star.close(); star.fill()
color(242,247,255).setFill(); NSBezierPath(ovalIn:NSRect(x:265,y:753,width:16,height:16)).fill()
NSBezierPath(ovalIn:NSRect(x:426,y:837,width:11,height:11)).fill()
NSGraphicsContext.restoreGraphicsState()
let destination = CGImageDestinationCreateWithURL(URL(fileURLWithPath:output) as CFURL,
    UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(destination, ctx.makeImage()!, nil)
precondition(CGImageDestinationFinalize(destination))
