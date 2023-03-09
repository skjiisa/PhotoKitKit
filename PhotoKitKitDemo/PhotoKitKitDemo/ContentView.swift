//
//  ContentView.swift
//  PhotoKitKitDemo
//
//  Created by Elaine Lyons on 3/8/23.
//

import SwiftUI
import PhotoKitKit

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
