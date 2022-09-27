//
//  MapUtils.swift
//  InteractiveMap
//
//  Created by GrandSir on 15.09.2022.
//

import SwiftUI

// drawing paths with given command and coordinates
@available(macOS 10.15, iOS 13.0, *)
func executeCommand(svgData: PathData, rect: CGRect) -> Path {
    var path = Path()
    
    var lastPoint : CGPoint = .zero
    var control1 : CGPoint? = nil
    var control2 : CGPoint? = nil
    
    for pathExecutionCommand in svgData.path {
        if pathExecutionCommand.command == "M" {
            path.move(to: pathExecutionCommand.coordinate)
            lastPoint = pathExecutionCommand.coordinate
        }
        
        if pathExecutionCommand.command == "m" {
            let point = CGPoint(x: pathExecutionCommand.coordinate.x + lastPoint.x, y: pathExecutionCommand.coordinate.y + lastPoint.y)
            
            path.move(to: point)
            lastPoint = point
        }
        
        if pathExecutionCommand.command == "V" || pathExecutionCommand.command == "L" {
            path.addLine(to: pathExecutionCommand.coordinate)
            lastPoint = pathExecutionCommand.coordinate
        }
        
        if pathExecutionCommand.command == "v" ||  pathExecutionCommand.command == "l" {
            let point = CGPoint(x: pathExecutionCommand.coordinate.x + lastPoint.x, y: pathExecutionCommand.coordinate.y + lastPoint.y)
            
            path.addLine(to: point)
            lastPoint = point
        }
        
        if pathExecutionCommand.command == "z" || pathExecutionCommand.command == "Z" {
            path.closeSubpath()
        }
        
        if pathExecutionCommand.command == "C" {
            
            guard let c1 = control1 else {
                control1 = pathExecutionCommand.coordinate
                continue
            }
            
            guard let c2 = control2 else {
                control2 = pathExecutionCommand.coordinate
                continue
            }
            
            path.addCurve(to: pathExecutionCommand.coordinate, control1: c1, control2: c2)
            control1 = nil
            control2 = nil
            
            lastPoint = pathExecutionCommand.coordinate
        }
        
        if pathExecutionCommand.command == "c" {
            
            guard let c1 = control1 else {
                control1 = pathExecutionCommand.coordinate
                continue
            }
            
            guard let c2 = control2 else {
                control2 = pathExecutionCommand.coordinate
                continue
            }
            
            path.addCurve(to: CGPoint(x: pathExecutionCommand.coordinate.x + lastPoint.x, y: pathExecutionCommand.coordinate.y + lastPoint.y), control1: CGPoint(x: c1.x + lastPoint.x, y: c1.y + lastPoint.y), control2: CGPoint(x: c2.x + lastPoint.x, y: c2.y + lastPoint.y))
            
            control1 = nil
            control2 = nil
            
            lastPoint = CGPoint(x: pathExecutionCommand.coordinate.x + lastPoint.x, y: pathExecutionCommand.coordinate.y + lastPoint.y)
        }
    }
    
    // scale down paths
    if let svgBounds = svgData.svgBounds {
        let scaleHorizontal = rect.size.width / (svgBounds.width) ;
        let scaleVertical = rect.size.height / (svgBounds.height) ;
        let scale = min(scaleHorizontal, scaleVertical);
        
        var scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
        scaleTransform = scaleTransform.translatedBy(x: -svgBounds.origin.x, y: -svgBounds.origin.y)
        return path.applying(scaleTransform)
        
    }
    return path
    
}


/// Struct that holds every information of paths
/// - Parameters:
/// - name: Name of the province that is specified inside <path> element .
/// - id:  ID of the province that holds the `id` in <path> element.
/// - path: an array of `PathExecutionCommand`s that is parsed from `MapParser`
///
/// An example from a SVG file:
/// <path ... id="TUR2229" name="Aydin">
///
/// Where the `id` and `name` is wrapped into the `PathData` in `XMLParser`
///
///
@available(iOS 13.0, macOS 10.15, *)
public struct PathData : Identifiable {
    public var id : String = ""
    public var name: String = ""
    public var boundingBox: CGRect? = nil
    public var svgBounds: CGRect? = nil
    var path = [PathExecutionCommand]()


    public init(name: String, id: String, path: [PathExecutionCommand], boundingBox: CGRect) {
        self.name = name
        self.id = id
        self.path = path
        self.boundingBox = boundingBox
    }
    
    public init(name: String, id: String, path: [PathExecutionCommand]) {
        self.name = name
        self.id = id
        self.path = path
    }
    
    public init() {
        
    }
}

@available(iOS 13.0, macOS 10.15, *)
extension PathData : Equatable {
    public static func == (lhs: PathData, rhs: PathData) -> Bool {
        lhs.id == rhs.id
    }
}
