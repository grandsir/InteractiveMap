//
//  MapRenderer.swift
//  InteractiveMap
//
//  Created by GrandSir on 13.09.2022.
//

import SwiftUI

/// Struct that holds every information of province
public struct Province : Identifiable {
    var name: String
    public var id: String
    var path : [PathExecutionCommand]
    
    public init(name: String, id: String, path: [PathExecutionCommand]) {
        self.name = name
        self.id = id
        self.path = path
    }
}

@available(macOS 10.15, iOS 13.0, *)
public class MapParser : NSObject, XMLParserDelegate {
    
    var size: CGSize
    var provinces: [Province] = []
    var scaleAmount = 1.0
    
    var minX = Double.greatestFiniteMagnitude
    var maxX = -Double.greatestFiniteMagnitude
    var minY = Double.greatestFiniteMagnitude
    var maxY = -Double.greatestFiniteMagnitude
    
    
    var width : CGFloat = .zero
    var height : CGFloat = .zero

    
    /// Filename needed to parse SVG.
    /// Can be written with or without .svg extension.
    init(svgName: String, size: CGSize) {
        self.size = size
        
        super.init()
        
        self.parseSvg(fileName: svgName)
    }
    
    func parseSvg(fileName: String) {
        var filePath: String?
        
        
        // check if arg has .svg in its name, if not, add it.
        if (fileName.contains(".svg")) {
            filePath = Bundle.main.path(forResource: fileName, ofType: nil)
        }
        
        else {
            filePath = Bundle.main.path(forResource: fileName, ofType: "svg")
        }
        
        guard let filePath = filePath else {
            print("InteractiveMap Error: No File Found.")
            return
        }
        
        
        // parser configuration
        if let parser = XMLParser(contentsOf: URL(fileURLWithPath: filePath)) {
            parser.delegate = self
            parser.parse()
        }
        
    }
    
    // XMLParser Delegate
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {

        if elementName == "svg" {
            
            if let vBox = attributeDict["viewbox"]?.split(separator: " ") {
                width = CGFloat(Int(vBox[2]) ?? 0)
                height = CGFloat(Int(vBox[2]) ?? 0)
            }
            
            else {
                guard let vBox = attributeDict["viewBox"]?.split(separator: " ") else {
                    if let w = attributeDict["width"] {
                        width =  CGFloat(Int(w) ?? 0)
                    }
                    if let h = attributeDict["height"] {
                        height =  CGFloat(Int(h) ?? 0)
                    }
                    return
                }
                
                width = CGFloat(Int(vBox[2]) ?? 0)
                height = CGFloat(Int(vBox[3]) ?? 0)

                
            }
            let scaleMultiplier = size.width
            scaleAmount = max(scaleMultiplier / width, scaleMultiplier / height)
        }
        
        /*
         *
         * All svg based maps differentiate provinces and districts by seperating them in <path>
         * element. That's why we're looping through paths.
         *
         */
        
        if (elementName == "path") {
            
            var province = Province(name: attributeDict["name"] ?? attributeDict["id"] ?? "undefined", id: attributeDict["id"] ?? (attributeDict["name"] ?? UUID().uuidString), path: [])
            
            // Empty character
            var currentCommand: Character = "\0"
            var currentCoordinates = ""
            var isFirstLoop = true
            
            /*
             *****************************************************************************
             
             Additional: 'd' attribute in paths, known as the `geometry` attribute, contains all the information (coordinates, commands) about path that are needed for drawing operations.
             
             *****************************************************************************
             
             Algorithm:
             
             - First Loop: initialize first command (mostly M or m). Collect all "coordinates" related to that command.
             
             - Other Loops: when encountered a letter, scan every coordinate collected from the previous command. Convert them to integers using scanner, then add them as execution commands to related Province. Finally, replace previous command with new command. Repeat this process.
             
             *****************************************************************************
             */
            
            for char in attributeDict["d"]! {
                if (char.isLetter) {
                    // Initialize first command
                    
                    if isFirstLoop {
                        currentCommand = char
                        isFirstLoop = false
                    }
                    
                    else  {
                        // Sometimes scanner have trouble to identify blank spaces
                        let scanner = Scanner(string: currentCoordinates.replacingOccurrences(of: " ", with: ","))
                        
                        var x = 0.0
                        var y = 0.0
                        var prevValueScanned = false
                        
                        scanner.charactersToBeSkipped = ["\n", ","]
                        
                        // Scan for coordinates

                        while(!scanner.isAtEnd) {
                            let value = scanner.scanDouble()
                            if let value = value {
                                
                                if prevValueScanned {
                                    y = value * scaleAmount
                                    
                                    minY = min(value, minY)
                                    maxY = max(value, maxY)
                                    
                                    province.path.append(PathExecutionCommand(coordinate: CGPoint(x: x, y: y), command: String(currentCommand)))
                                }
                                
                                else {
                                    x = value * scaleAmount
                                    minX = min(x, minX)
                                    maxX = max(x, maxX)
                                }
                            }
                            
                            else {
                                print("Interactive Map Error: Found Invalid Coordinates Inside SVG")
                                print("Scanned string: \(scanner.string)")
                                break
                            }
                            
                            prevValueScanned.toggle()
                            
                        }
                        currentCoordinates = ""
                        currentCommand = char
                    }
                    
                    if (char == "z" || char == "Z") {
                        // .zero stands as a placeholder.
                        province.path.append(PathExecutionCommand(coordinate: .zero, command: String(char)))
                    }
                    continue
                }
                currentCoordinates.append(char)
            }
            provinces.append(province)
        }
    }
}

public struct PathExecutionCommand : CustomStringConvertible, Identifiable {
    public var id = UUID()
    var coordinate: CGPoint // (x, y)
    var command : String
    public var description: String { return "PathExecutionCommand(coordinate: \(coordinate), command: \(command))\n" }
    
    
    public init(coordinate : CGPoint, command: String) {
        self.coordinate = coordinate
        self.command = command
    }
}
