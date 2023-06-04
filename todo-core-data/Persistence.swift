//
//  Persistence.swift
//  todo-core-data
//
//  Created by Susumu Hoshikawa on 2023/06/04.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
//        for _ in 0..<10 {
//            let newItem = Item(context: viewContext)
//            newItem.timestamp = Date()
//        }
        do {
            try viewContext.save()
        } catch {
            // この実装を、エラーを適切に処理するコードに置き換えてください。
            // fatalError() を使用すると、アプリケーションはクラッシュログを生成し、終了してしまいます。
            // この関数は、開発中に役に立つかもしれませんが、出荷時のアプリケーションでは使用しないでください。
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "todo_core_data")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // この実装を、エラーを適切に処理するコードに置き換えてください。
                // fatalError() を使用すると、アプリケーションはクラッシュログを生成して終了します。
                // この関数は、開発中に役に立つかもしれませんが、出荷時のアプリケーションでは使用しないでください。

                /*
                 ここでエラーが発生する典型的な理由は以下の通りです：
                 - 親ディレクトリが存在しないか、作成できないか、または書き込みが禁止されています。
                 - デバイスがロックされている場合、パーミッションやデータ保護により、永続ストアにアクセスできない。
                 - デバイスの容量が不足しています。
                 - ストアを現在のモデルバージョンに移行することができませんでした。
                 エラーメッセージを確認し、実際の問題が何であったかを判断してください。
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
