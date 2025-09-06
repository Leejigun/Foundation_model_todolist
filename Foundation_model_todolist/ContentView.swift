//
//  ContentView.swift
//  Foundation_model_todolist
//
//  Created by bimo.ez on 9/6/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TodoListView(modelContext: modelContext)
    }
}

#Preview {
    ContentView()
}
