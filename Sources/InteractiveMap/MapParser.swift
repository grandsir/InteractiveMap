//
//  MapRenderer.swift
//  InteractiveMap
//
//  Created by GrandSir on 13.09.2022.
//

import SwiftUI

@available(macOS 10.15, iOS 13.0, *)
public class MapParser : NSObject, XMLParserDelegate {
    
    var size: CGSize
    var pathDatas: [PathData] = []
    var scaleAmount = 1.0
    
    var minX = Double.greatestFiniteMagnitude
    var maxX = -Double.greatestFiniteMagnitude
    var minY = Double.greatestFiniteMagnitude
    var maxY = -Double.greatestFiniteMagnitude
    
    var width : CGFloat = .zero
    var height : CGFloat = .zero
    
    var bounds : CGRect = .zero

    
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
            print("InteractiveMap Error: File Not Found.")
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
        
        /*
         *
         * All svg based maps differentiate provinces and districts by seperating them in <path>
         * element. That's why we're looping through paths.
         *
         */
        if (elementName == "path") {
            var pathData = PathData(name: attributeDict["name"] ?? attributeDict["id"] ?? "undefined", id: attributeDict["id"] ?? (attributeDict["name"] ?? UUID().uuidString), path: [])
            
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
                                    
                                    pathData.path.append(PathExecutionCommand(coordinate: CGPoint(x: x, y: y), command: String(currentCommand)))
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
                        pathData.path.append(PathExecutionCommand(coordinate: .zero, command: String(char)))
                    }
                    continue
                }
                currentCoordinates.append(char)
            }
            pathDatas.append(pathData)
        }
    }
    
    public func parserDidEndDocument(_ parser: XMLParser) {
        self.computeBounds()
    }
    
    
    public func computeBounds() {
        bounds.origin.x = CGFloat.greatestFiniteMagnitude
        bounds.origin.y = CGFloat.greatestFiniteMagnitude
        var maxx = -CGFloat.greatestFiniteMagnitude
        var maxy = -CGFloat.greatestFiniteMagnitude

        for index in 0..<pathDatas.count {
            var path = pathDatas[index]
            let b = executeCommand(svgData: path, rect: CGRect(x: 0, y: 0, width: size.width, height: size.height)).boundingRect;
            
            if(b.origin.x < bounds.origin.x) {
                bounds.origin.x = b.origin.x
            }
            
            if(b.origin.y < bounds.origin.y){
                bounds.origin.y = b.origin.y;
            }
            if(b.origin.x + b.size.width > maxx){
                maxx = b.origin.x + b.size.width;
            }
            
            if(b.origin.y + b.size.height > maxy){
                maxy = b.origin.y + b.size.height;
            }
            path.boundingBox = b
            
            pathDatas[index] = path
        }
        
        bounds.size.width = maxx - bounds.origin.x;
        bounds.size.height = maxy - bounds.origin.y;
        
        for index in 0..<pathDatas.count {
            var path = pathDatas[index]
            
            path.svgBounds = bounds
            
            pathDatas[index] = path
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
