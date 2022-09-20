//
//  MapRenderer.swift
//  InteractiveMap
//
//  Created by GrandSir on 14.09.2022.
//

import SwiftUI

/**
 A shape that unifies the entire map when combined with other `ProvinceShape`s.
 - Parameters :
 - province: A struct that holds everything about province (`id`, `name`, `path`, `rect`),
 */
@available(iOS 13.0, macOS 10.15, *)
public struct ProvinceShape : Shape {
    let province :  Province
    
    public func path(in rect: CGRect) -> Path {
        let path = executeCommand(pathCommands: province.path)
        return path
    }
    
    public init (_ province: Province) {
        self.province = province
    }
}


/// Default attributes for Map
@available(iOS 13.0, macOS 10.15, *)
public struct Attributes {
    public var strokeWidth : Double
    public var strokeColor : Color
    public var background: Color
    
    
    public init(
        strokeWidth : Double = 1.2,
        strokeColor: Color = .black,
        background: Color = Color(.sRGB, white: 0.5, opacity: 1)
    ) {
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.background = background
    }
}

/**
  An Unified Type of `ProvinceShape`s that is needed to draw an InteractiveMap

 -  Parameters:
 - content: returns a `Province` as parameter to the closure, which is needed to draw `ProvinceShape`'s
 - svgName: Filename needed to parse SVG. Can be written with or without .svg extension.

 - Resizes itself to the current frame. Takes all space when not specified
 
  To draw `MapView` to screen, you have to just provide an `svg` name and `Province` as closure parameter
  ```
    struct ContentView : View {
        var body: some View {
            MapView(svgName: "tr) { province
                ProvinceShape(province: province)
            }
        }
    }
 ```
 `MapView` does not use any default attributes if not specified.
 
  if you want `MapView` to use be colored that in any manner, you can either use `.initWithAttributes`
  ```
    struct ContentView : View {
        var body: some View {
            MapView(svgName: "tr) { province
                ProvinceShape(province: province)
                    .initWithAttributes()
            }
        }
    }
 ```
 If you want to edit attributes of the map like `strokeColor`, `strokeWidth` or `provinceColor`, you can initialize `Attributes` struct within `.initWithAttributes` for that.
 
 ``.initWithAttributes(.init(strokeWidth: 2, strokeColor: .red, background: .black))``

 or instead of using the method that `InteractiveMap` provides, you can just use your own attributes that `SwiftUI` provides to `Shape`'s. There is no limitaton.
 ```
   struct ContentView : View {
       var body: some View {
           MapView(svgName: "tr") { province
               ProvinceShape(province: province)
                   .stroke(Color.red)
           }
       }
   }
```
 */
@available(iOS 13.0, macOS 10.15, *)
public struct MapView<Content> : View where Content : View{
    
    /// MapParser that parses SVG map
    @State private var mapParser : MapParser?
    
    /// name of the SVG, can be written with or without file extension
    let svgName : String
    
    /// Closure that is needed to customize the map,
    var content: ((_ province: Province) -> Content)
    
    
    public init(svgName: String, @ViewBuilder content: @escaping (_ province: Province) -> Content) {
        self.svgName = svgName
        self.content = content
    }
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                // the frame is not initialized yet. That is, we're waiting for .onAppear to be triggered.
                if let mapParser = mapParser {
                    ForEach(mapParser.provinces) { province in
                        content(province)
                    }
                }
            }
            .onAppear {
                mapParser = MapParser(svgName: svgName, size: geo.size)
            }
        }
    }
}

@available(iOS 13.0, macOS 10.15, *)
extension ProvinceShape {
    /// Uses default Attributes for coloring map
    /// - `strokeWidth : Double = 1.2,`
    /// - `strokeColor: Color = .black,`
    /// - `background: Color = Color(.sRGB, white: 0.5, opacity: 1)`
    func initWithAttributes() -> some View {
        let attributes = Attributes()
        return self
            .stroke(attributes.strokeColor, lineWidth: attributes.strokeWidth)
            .background(self.fill(attributes.background))
    }
    
    func initWithAttributes(_ attributes : Attributes) -> some View {
        self
            .stroke(attributes.strokeColor, lineWidth: attributes.strokeWidth)
            .background(self.fill(attributes.background))
    }
}

