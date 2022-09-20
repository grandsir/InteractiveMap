//
//  MapUtils.swift
//  InteractiveMap
//
//  Created by GrandSir on 15.09.2022.
//

import SwiftUI

@available(macOS 10.15, iOS 13.0, *)
func executeCommand(pathCommands: [PathExecutionCommand]) -> Path {
    var path = Path()
    
    var lastPoint : CGPoint = .zero
    var control1 : CGPoint? = nil
    var control2 : CGPoint? = nil
    
    for pathExecutionCommand in pathCommands {
        
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
    
    
    return path
    
}


/// Struct that holds every information of province
/// - Parameters:
/// - name: Name of the province that is specified inside <path> element .
/// - id:  ID of the province that holds the `id` in <path> element.
/// - path: an array of `PathExecutionCommand`s that is parsed from `MapParser`
///
/// An example from a SVG file:
/// <path ... id="TUR2229" name="Aydin">
///
/// Where the `id` and `name` is wrapped into the `Province` in `XMLParser`
///
///
@available(macOS 10.15, iOS 13.0, *)
public struct Province : Identifiable {
    public var name: String
    public var id: String
    var path : [PathExecutionCommand]
    
    public init(name: String, id: String, path: [PathExecutionCommand]) {
        self.name = name
        self.id = id
        self.path = path
    }
}



@available(iOS 13.0, macOS 10.15, *)
extension Province {
    public static var EmptyProvince : Province {
        Province(name: "", id: "", path: [PathExecutionCommand(coordinate: CGPoint(x: 0, y: 0), command: "")])
    }
}

@available(iOS 13.0, macOS 10.15, *)
extension Province : Equatable {
    public static func == (lhs: Province, rhs: Province) -> Bool {
        lhs.id == rhs.id
    }
}
