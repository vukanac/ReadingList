import Foundation
import CoreData
import CloudKit

protocol BookUpstreamChangeProcessor: UpstreamChangeProcessor {
    func processLocalChanges(_ books: [Book], context: NSManagedObjectContext, remote: BookCloudKitRemote)
    var unprocessedChangedBooksRequest: NSFetchRequest<Book> { get }
}

extension BookUpstreamChangeProcessor {

    func processLocalChanges(_ objects: [NSManagedObject], context: NSManagedObjectContext, remote: BookCloudKitRemote) {
        guard let books = objects as? [Book] else { fatalError("Incorrect object type") }
        print("\(debugDescription) processing \(books.count) objects")
        processLocalChanges(books, context: context, remote: remote)
    }

    var unprocessedChangedObjectsRequest: NSFetchRequest<NSFetchRequestResult> {
        return unprocessedChangedBooksRequest as! NSFetchRequest<NSFetchRequestResult>
    }
}
