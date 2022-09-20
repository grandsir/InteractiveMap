//
//  MapRenderer.swift
//  InteractiveMap
//
//  Created by GrandSir on 14.09.2022.
//

import SwiftUI

/**
 A shape that unifies the entire map when combined with other shapes.
 */
@available(iOS 13.0, macOS 10.15, *)
public struct ProvinceShape : Shape {
    let province :  Province
    
    public func path(in rect: CGRect) -> Path {
        let path = executeCommand(pathCommands: province.path)
        return path
    }
}

/**
  A MegaShape that consist of shapes

 -  Parameters:
 - content: returns a `Province` as parameter to the closure, which is needed to draw `ProvinceShape`'s
 - svgName: Filename needed to parse SVG. Can be written with or without .svg extension.

 -  Attributes:
 - Resizes itself to the current frame. Takes all space when not specified
 
  ```Usage:

    struct ContentView : View {
        var body: some View {
            MapView(svgName: "tr) { province in
                ProvinceShape(province: province)
                    .stroke()
            }
        }
    }
 ```
 
 You are allowed add any attribute to `ProvinceShape` that `SwiftUI` provides to `Shape`'s. There is no limitation.
 
*/
@available(iOS 13.0, macOS 10.15, *)
public struct MapView<Content> : View where Content : View {
    @State private var mapParser : MapParser?
    /// name of the SVG
    let svgName : String
    /// Closure that is needed to customize the map,
    var content: ((_ province: Province) -> Content)

    public init(svgName: String,  content: @escaping (_ province: Province) -> Content) {
        self.svgName = svgName
        self.content = content
    }

    public var body: some View {
        GeometryReader { geo in
            ZStack {
                // the frame is not initialized yet. That is, we're waiting  for.onAppear to be triggered.
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
