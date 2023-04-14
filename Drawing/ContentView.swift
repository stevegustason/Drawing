//
//  ContentView.swift
//  Drawing
//
//  Created by Steven Gustason on 4/12/23.
//

import SwiftUI

/*
 // Day 1 content
// Instead of paths, which use absolute coordinates, we can use shapes. Because we're handed the size the shape will be used at, we know exactly how big to draw our path and don't need to rely on fixed coordinates.
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))

        return path
    }
}

// Paths are designed to do one specific thing, whereas shapes have flexibility of drawing space and you can pass them parameters to customize them. For example, our arc has three parameters below. Note that arcs are usually not InsettableShapes like circles are, which means you can't use a strokeBorder because the shape can't be inset or reduced inwards. To fix that, we add an insetAmount variable and a inset(by:) function, and then add that it now conforms to InsettableShape.
struct Arc: Shape, InsettableShape {
    var startAngle: Angle
    var endAngle: Angle
    var clockwise: Bool
    var insetAmount = 0.0
    
    /*
    func path(in rect: CGRect) -> Path {
            var path = Path()
            path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)

            return path
        }
     */

    // In this version of the above function, we adjust our starting point by 90 degrees so that 0 is straight up, and flip the direction so that SwiftUI draws the way you would expect.
    func path(in rect: CGRect) -> Path {
        let rotationAdjustment = Angle.degrees(90)
        let modifiedStart = startAngle - rotationAdjustment
        let modifiedEnd = endAngle - rotationAdjustment

        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2 - insetAmount, startAngle: modifiedStart, endAngle: modifiedEnd, clockwise: !clockwise)

        return path
    }
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.insetAmount += amount
        return arc
    }
}


struct ContentView: View {
    var body: some View {
        VStack {
            // Paths let us draw using coordinate drawing instructions. You must provide a single parameter in the closure, which is the path to draw into. Paths use fixed coordinates, so they'll appear different on different screen sizes.
            Path { path in
                path.move(to: CGPoint(x: 200, y: 100))
                path.addLine(to: CGPoint(x: 100, y: 300))
                path.addLine(to: CGPoint(x: 300, y: 300))
                path.addLine(to: CGPoint(x: 200, y: 100))
                /*
                // We can use closeSubpath to make sure our last line connects neatly instead of appearing broken.
                path.closeSubpath()
                 */
            }
            /*
            // We can use fill to fill in the shape with a color
            .fill(.blue)
             */
            /*
            // Or we can use stroke to draw around the path, rather than filling it in
            .stroke(.blue, lineWidth: 10)
            */
            // Instead of closeSubpath, we can also use StrokeStyle, which lets us control how every line is connected to the line after it (lineJoin), and how every line should be drawn that ends without a connection (lineCap).
            .stroke(.blue, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
            
            // We can then use our shape to create our triangle at any given size.
            Triangle()
                .stroke(.red, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .frame(width: 100, height: 100)
            
            // For SwiftUI, 0 degrees is directly to the right, rather than straight up. Shapes measure their coordinates from bottom-left corner rather than top-left corner, which means SwiftUI goes the other way around from one angle to another.
            Arc(startAngle: .degrees(0), endAngle: .degrees(110), clockwise: true)
                .stroke(.blue, lineWidth: 10)
                .frame(width: 100, height: 200)
            
            // If we create a shape without a specific size, it will automatically take up all available space.
            Circle()
            /*
            // If we use stroke to put a border on our circle, it fills inward and outward equally, so with a circle that takes up the whole screen, the border will be cut off.
                .stroke(.blue, lineWidth: 40)
             */
            // However, if we use strokeBorder, swift strokes the inside of the circle, rather than centering on the edge of the circle.
                .strokeBorder(.blue, lineWidth: 40)
            
            // Now that we have made Arc conform to InsettableShape above, we can use strokeBorder here too
            Arc(startAngle: .degrees(-90), endAngle: .degrees(90), clockwise: true)
                .strokeBorder(.blue, lineWidth: 40)
        }
    }
}
*/

struct Flower: Shape {
    // How much to move this petal away from the center
    var petalOffset: Double = -20

    // How wide to make each petal
    var petalWidth: Double = 100

    func path(in rect: CGRect) -> Path {
        // The path that will hold all petals
        var path = Path()

        // Count from 0 up to pi * 2, moving up pi / 8 each time
        for number in stride(from: 0, to: Double.pi * 2, by: Double.pi / 8) {
            // rotate the petal by the current value of our loop
            let rotation = CGAffineTransform(rotationAngle: number)

            // move the petal to be at the center of our view
            let position = rotation.concatenating(CGAffineTransform(translationX: rect.width / 2, y: rect.height / 2))

            // create a path for this petal using our properties plus a fixed Y and height
            let originalPetal = Path(ellipseIn: CGRect(x: petalOffset, y: 0, width: petalWidth, height: rect.width / 2))

            // apply our rotation/position transformation to the petal
            let rotatedPetal = originalPetal.applying(position)

            // add it to our main path
            path.addPath(rotatedPetal)
        }

        // now send the main path back
        return path
    }
}

struct ColorCyclingCircle: View {
    var amount = 0.0
    var steps = 100

    var body: some View {
        ZStack {
            ForEach(0..<steps) { value in
                Circle()
                    .inset(by: Double(value))
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                color(for: value, brightness: 1),
                                color(for: value, brightness: 0.5)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2
                    )
            }
        }
    }

    func color(for value: Int, brightness: Double) -> Color {
        var targetHue = Double(value) / Double(steps) + amount

        if targetHue > 1 {
            targetHue -= 1
        }

        return Color(hue: targetHue, saturation: 1, brightness: brightness)
    }
}

struct ContentView: View {
    @State private var petalOffset = -20.0
    @State private var petalWidth = 100.0
    @State private var colorCycle = 0.0

    var body: some View {
        VStack {
            Flower(petalOffset: petalOffset, petalWidth: petalWidth)
                .fill(.red, style: FillStyle(eoFill: true))
            
            Text("Offset")
            Slider(value: $petalOffset, in: -40...40)
                .padding([.horizontal, .bottom])
            
            Text("Width")
            Slider(value: $petalWidth, in: 0...100)
                .padding(.horizontal)
            
            Text("Hello World")
                .frame(width: 100, height: 100)
            // We can use an image as a border, including using the sourceRect parameter to use as the source of the drawing
                .border(ImagePaint(image: Image("Zelda"), sourceRect: CGRect(x: 0, y: 0.25, width: 1, height: 0.5), scale: 0.1), width: 30)
            
            Capsule()
            // ImagePaint can be used for backgrounds and for strokes
                .strokeBorder(ImagePaint(image: Image("Zelda"), scale: 0.1), lineWidth: 20)
                .frame(width: 150, height: 100)
            
            ColorCyclingCircle(amount: colorCycle)
                .frame(width: 300, height: 300)
            // drawingGroup tells SwiftUI it should render the contents of the view into an off-screen image before putting it back onto the screen as a single rendered output, which is significantly faster. Behind the scenes this is powered by Metal, which is Apple’s framework for working directly with the GPU for extremely fast graphics. 
                .drawingGroup()
            
            
            Slider(value: $colorCycle)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
