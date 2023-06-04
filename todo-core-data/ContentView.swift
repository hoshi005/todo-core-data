//
//  ContentView.swift
//  todo-core-data
//
//  Created by Susumu Hoshikawa on 2023/06/04.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            Home()
                .navigationTitle("To-Do")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
