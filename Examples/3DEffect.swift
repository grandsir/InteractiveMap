//
//  ContentView.swift
//  Examples
//
//  Created by GrandSir on 19.09.2022.
//

import SwiftUI
import InteractiveMap

struct ContentView: View {
    @State private var clickedPath = PathData.EmptyPath
    var body: some View {
        VStack {
            Text(clickedPath.name.isEmpty ? "" : "\(clickedPath.name) is clicked!" )
                .font(.largeTitle)
                .padding(.bottom, 15)
            InteractiveMap(svgName: "tr") { pathData in 
                InteractiveShape(from: pathData)
                    .initWithAttributes()
                    .shadow(color: clickedPath == pathData ? .white : .clear, radius: 6)
                    .onTapGesture {
                        clickedPath = pathData
                    }
                    .scaleEffect(clickedPath == pathData ? 1.4 : 1)
                    .animation(.easeInOut(duration: 0.2), value: clickedPath)
                    .zIndex(clickedPath == pathData ? 2 : 1)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
