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
            Text(clickedPath.name.isEmpty ? "" : "\(clickedProvince.name) is clicked!" )
                .font(.largeTitle)
                .padding(.bottom, 15)
            InteractiveMap(svgName: "tr") { pathData in // is a PathData
                InteractiveShape(pathData)
                    .initWithAttributes(.init(strokeWidth: 2, strokeColor: .black, background: .black.opacity(0.3)))
                    .shadow(color: clickedProvince == province ? .white : .clear, radius: 6)
                    .onTapGesture {
                        clickedPath = pathData
                    }
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
