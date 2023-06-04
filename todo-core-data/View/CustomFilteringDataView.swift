//
//  CustomFilteringDataView.swift
//  todo-core-data
//
//  Created by Susumu Hoshikawa on 2023/06/04.
//

import SwiftUI

struct CustomFilteringDataView<Content: View>: View {
    @FetchRequest private var result: FetchedResults<Task>
    var content: (Task) -> Content
    init(displayPendingTask: Bool, filterDate: Date, content: @escaping (Task) -> Content) {
        // taskのフィルタリングのための Predicate を作成.
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: filterDate)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay)!
        
        // argumentArrayを利用すれば、もうちょっと単純に値を設定することができるっぽい？
        let predicate = NSPredicate(format: "date >= %@ AND date <= %@ AND isCompleted == %i", (startOfDay as NSDate), (endOfDay as NSDate), !displayPendingTask)
        
        _result = FetchRequest(entity: Task.entity(), sortDescriptors: [
            NSSortDescriptor(keyPath: \Task.date, ascending: false)
        ], predicate: predicate, animation: .easeInOut(duration: 0.25))
        
        self.content = content
    }
    
    var body: some View {
        Group {
            if result.isEmpty {
                Text("タスクが見つかりませんでした〜")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(result) { task in
                    content(task)
                }
            }
        }
    }
}

struct CustomFilteringDataView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
