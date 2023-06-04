//
//  Home.swift
//  todo-core-data
//
//  Created by Susumu Hoshikawa on 2023/06/04.
//

import SwiftUI

struct Home: View {
    
    /// View Properties
    @Environment(\.self) private var env
    @State private var filterDate: Date = .init()
    @State private var showPendingTasks = true
    @State private var showCompletedTasks = true
    
    var body: some View {
        List {
            DatePicker(selection: $filterDate, displayedComponents: [.date]) {
                
            }
            .labelsHidden()
            .datePickerStyle(.graphical)
            
            DisclosureGroup(isExpanded: $showPendingTasks) {
                // カスタムCore Data Filter にて、選択された日の pending tasks のみを表示する領域.
                CustomFilteringDataView(displayPendingTask: true, filterDate: filterDate) {
                    TaskRow(task: $0, isPendingTask: true)
                }
            } label: {
                Text("Pending Task's")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            DisclosureGroup(isExpanded: $showCompletedTasks) {
                // カスタムCore Data Filter にて、選択された日の completed tasks のみを表示する領域.
                CustomFilteringDataView(displayPendingTask: false, filterDate: filterDate) {
                    TaskRow(task: $0, isPendingTask: false)
                }
            } label: {
                Text("Completed Task's")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    // 空のタスクを作成し、保留中のタスクセクションを表示する.
                    do {
                        let task = Task(context: env.managedObjectContext)
                        task.id = .init()
                        task.date = filterDate
                        task.title = ""
                        task.isCompleted = false
                        
                        try env.managedObjectContext.save()
                        showPendingTasks = true
                    } catch {
                        print(error.localizedDescription)
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("New Task")
                    }
                    .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct TaskRow: View {
    @ObservedObject var task: Task
    var isPendingTask: Bool
    /// View Properties.
    @Environment(\.self) private var env
    @FocusState private var showKeyboard: Bool
    
    var body: some View {
        HStack(spacing: 12.0) {
            Button {
                task.isCompleted.toggle()
                save()
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4.0) {
                TextField("Task Title", text: .init(get: {
                    return task.title ?? ""
                }, set: { value in
                    task.title = value
                }))
                .focused($showKeyboard)
                .onSubmit {
                    // キーボードを閉じたときに、タスクのタイトルが空かどうかを確認する.
                    // 空であれば、その空のタスクを削除する.
                    removeEmptyTask()
                    save()
                }
                
                // custom date picker.
                Text((task.date ?? .init()).formatted(date: .omitted, time: .shortened))
                    .font(.callout)
                    .foregroundColor(.gray)
                    .overlay {
                        DatePicker(selection: .init(get: {
                            return task.date ?? .init()
                        }, set: { value in
                            task.date = value
                            // 日付が更新されていたら保存する.
                            save()
                        }), displayedComponents: [.hourAndMinute]) {
                            
                        }
                        .labelsHidden()
                        .blendMode(.destinationOver)
                    }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onAppear {
            // テキストフィールドが空の状態でキーボードが表示されるため、
            // タスクを作成するたびに自動的にキーボードが表示され、
            // タスクタイトルが入力されます。
            if (task.title ?? "").isEmpty {
                showKeyboard = true
            }
        }
        // ユーザがアプリを離れたときのコンテンツの検証.
        .onChange(of: env.scenePhase) { newValue in
            // ユーザーがタスクタイトルを入力せずにアプリを閉じたり最小化したりして、
            // 最終的にアプリを閉じたとき、空のタスクが残っていることを考慮してください。
            // そのような場合、アプリケーションの状態がアクティブでないときは、空のタスクを破棄しています。
            if newValue != .active {
                removeEmptyTask()
                save()
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                env.managedObjectContext.delete(task)
                save()
            } label: {
                Image(systemName: "trash.fill")
            }
        }
    }
    
    /// context saving method.
    func save() {
        do {
            try env.managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Removing empty tasks.
    func removeEmptyTask() {
        if (task.title ?? "").isEmpty {
            // タスク削除.
            env.managedObjectContext.delete(task)
        }
    }
}
