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

/*
// Day 2 content
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
*/

/*
// Day 3 content
struct Trapezoid: Shape {
    var insetAmount: Double
    
    // Using animatableData allows us to animate something that otherwise would have just jumped from state to state - essentially it allows us to animate changes to shapes. Over the length of the animation, swift will set the animatableData property of our shape to the latest interpolated value until it reaches its target.
    var animatableData: Double {
        get { insetAmount }
        set { insetAmount = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: CGPoint(x: insetAmount, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - insetAmount, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))

        return path
   }
}

struct Checkerboard: Shape {
    var rows: Int
    var columns: Int
    
    // AnimatablePair allows us to animate two different values that are changing simultaneously
    var animatableData: AnimatablePair<Double, Double> {
        get {
           AnimatablePair(Double(rows), Double(columns))
        }

        set {
            // We can then set the first and second values here over time
            rows = Int(newValue.first)
            columns = Int(newValue.second)
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // figure out how big each row/column needs to be
        let rowSize = rect.height / Double(rows)
        let columnSize = rect.width / Double(columns)

        // loop over all rows and columns, making alternating squares colored
        for row in 0..<rows {
            for column in 0..<columns {
                if (row + column).isMultiple(of: 2) {
                    // this square should be colored; add a rectangle here
                    let startX = columnSize * Double(column)
                    let startY = rowSize * Double(row)

                    let rect = CGRect(x: startX, y: startY, width: columnSize, height: rowSize)
                    path.addRect(rect)
                }
            }
        }

        return path
    }
}

struct Spirograph: Shape {
    let innerRadius: Int
    let outerRadius: Int
    let distance: Int
    let amount: Double
    
    func gcd(_ a: Int, _ b: Int) -> Int {
        var a = a
        var b = b

        while b != 0 {
            let temp = b
            b = a % b
            a = temp
        }

        return a
    }
    
    func path(in rect: CGRect) -> Path {
        let divisor = gcd(innerRadius, outerRadius)
        let outerRadius = Double(self.outerRadius)
        let innerRadius = Double(self.innerRadius)
        let distance = Double(self.distance)
        let difference = innerRadius - outerRadius
        let endPoint = ceil(2 * Double.pi * outerRadius / Double(divisor)) * amount

        var path = Path()

        for theta in stride(from: 0, through: endPoint, by: 0.01) {
            var x = difference * cos(theta) + distance * cos(difference / outerRadius * theta)
            var y = difference * sin(theta) - distance * sin(difference / outerRadius * theta)

            x += rect.width / 2
            y += rect.height / 2

            if theta == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        return path
    }
}

struct ContentView: View {
    @State private var insetAmount = 50.0
    @State private var rows = 4
    @State private var columns = 4
    
    @State private var innerRadius = 125.0
    @State private var outerRadius = 75.0
    @State private var distance = 25.0
    @State private var amount = 1.0
    @State private var hue = 0.6
    
    var body: some View {
        /*
         Image("Zelda")
         // Color multiplly basically puts a colored filter on your image
         .colorMultiply(.red)
         */
        
        /*
         // Screen inverts a color, performs a multiply, and then inverts them again to give a brighter image
         VStack {
         ZStack {
         Circle()
         .fill(.red)
         .frame(width: 200 * amount)
         .offset(x: -50, y: -80)
         .blendMode(.screen)
         
         Circle()
         .fill(.green)
         .frame(width: 200 * amount)
         .offset(x: 50, y: -80)
         .blendMode(.screen)
         
         Circle()
         .fill(.blue)
         .frame(width: 200 * amount)
         .blendMode(.screen)
         }
         .frame(width: 300, height: 300)
         
         Image("Zelda")
         .resizable()
         .scaledToFit()
         .frame(width: 200, height: 200)
         // Saturation lets us control how much color is used in an image
         .saturation(amount)
         .blur(radius: (1 - amount) * 20)
         
         Slider(value: $amount)
         .padding()
         }
         .frame(maxWidth: .infinity, maxHeight: .infinity)
         .background(.black)
         .ignoresSafeArea()
         */
        
        /*
         Trapezoid(insetAmount: insetAmount)
         .frame(width: 200, height: 100)
         .onTapGesture {
         withAnimation {
         insetAmount = Double.random(in: 10...90)
         }
         }
         */
        
        /*
         Checkerboard(rows: rows, columns: columns)
         .onTapGesture {
         withAnimation(.linear(duration: 3)) {
         rows = 8
         columns = 16
         }
         }
         */
        
        VStack(spacing: 0) {
            Spacer()
            
            Spirograph(innerRadius: Int(innerRadius), outerRadius: Int(outerRadius), distance: Int(distance), amount: amount)
                .stroke(Color(hue: hue, saturation: 1, brightness: 1), lineWidth: 1)
                .frame(width: 300, height: 300)
            
            Spacer()
            
            Group {
                Text("Inner radius: \(Int(innerRadius))")
                Slider(value: $innerRadius, in: 10...150, step: 1)
                    .padding([.horizontal, .bottom])
                
                Text("Outer radius: \(Int(outerRadius))")
                Slider(value: $outerRadius, in: 10...150, step: 1)
                    .padding([.horizontal, .bottom])
                
                Text("Distance: \(Int(distance))")
                Slider(value: $distance, in: 1...150, step: 1)
                    .padding([.horizontal, .bottom])
                
                Text("Amount: \(amount, format: .number.precision(.fractionLength(2)))")
                Slider(value: $amount)
                    .padding([.horizontal, .bottom])
                
                Text("Color")
                Slider(value: $hue)
                    .padding(.horizontal)
            }
        }
    }
}
*/

// Day 4 content
struct Arrow: InsettableShape {
    var insetAmount = 0.0

    var animatableData: Double {
        get { insetAmount }
        set { insetAmount = newValue}
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.height - insetAmount))
        path.addLine(to: CGPoint(x: rect.midX, y: insetAmount))
        path.addLine(to: CGPoint(x: insetAmount, y: rect.height * 0.33))
        path.move(to: CGPoint(x: rect.midX, y: insetAmount))
        path.addLine(to: CGPoint(x: rect.width - insetAmount, y: rect.height * 0.33))

        return path
    }

    func inset(by amount: CGFloat) -> some InsettableShape {
        var arrow = self
        arrow.insetAmount += amount
        return arrow
    }
}

struct ColorCyclingRectangle: View {
    var amount = 0.0
    var steps = 100

    var body: some View {
        ZStack {
            ForEach(0..<steps) { value in
                Rectangle()
                    .inset(by: Double(value))
                    .strokeBorder(color(for: value, brightness: 1), lineWidth: 2)
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
    @State private var lineWidth = 1.0
    
    @State private var colorCycle = 0.0

    var body: some View {
        
        VStack {
            Arrow()
                .strokeBorder(.blue, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            
            Spacer()
            
            Button("Change line width") {
                withAnimation(.easeInOut(duration: 1)) {
                    lineWidth = Double.random(in: 1...20)
                }
            }
            
            ColorCyclingRectangle(amount: colorCycle)
                            .frame(width: 300, height: 300)

            Slider(value: $colorCycle)
                .padding()
        }
    }
}
 
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
