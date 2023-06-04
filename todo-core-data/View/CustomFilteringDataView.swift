//
//  CustomFilteringDataView.swift
//  todo-core-data
//
//  Created by Susumu Hoshikawa on 2023/06/04.
//

import SwiftUI

struct CustomFilteringDataView<Content: View>: View {
    @FetchRequest private var result: FetchedResults<Task>
    var content: ([Task], [Task]) -> Content
    init(filterDate: Date, @ViewBuilder content: @escaping ([Task], [Task]) -> Content) {
        // taskのフィルタリングのための Predicate を作成.
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: filterDate)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay)!
        
        let predicate = NSPredicate(format: "date >= %@ AND date <= %@", argumentArray: [startOfDay, endOfDay])
        
        _result = FetchRequest(entity: Task.entity(), sortDescriptors: [
            NSSortDescriptor(keyPath: \Task.date, ascending: false)
        ], predicate: predicate, animation: .easeInOut(duration: 0.25))
        
        self.content = content
    }
    
    var body: some View {
        content(separateTasks().0, separateTasks().1)
    }
    
    func separateTasks() -> ([Task], [Task]) {
        let pendingTasks = result.filter { !$0.isCompleted }
        let completedTasks = result.filter { $0.isCompleted }
        
        return (pendingTasks, completedTasks)
    }
}

struct CustomFilteringDataView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
