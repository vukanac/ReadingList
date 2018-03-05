import CoreData

/**
 A CompoundFetchedResultsController is a wrapper of a number of inner NSFetchedResultsControllers.
 The wrapper flattens the sections produced by the inner controllers, behaving as if all sections
 were fetched by a single controller. Additionally, change notifications are mapped before being
 passed to the optional NSFetchedResultsControllerDelegate property, so that the section indices
 in the notifications reflect the flattened section indicies.
 
 Example use case: a table where sections should be ordered in mutually opposing ways. E.g., if
 section 1 should be ordered by propery A ascending, but section 2 should be ordered by property A
 descending. In this case, two controllers can be created - one ordering ascending, the other de-
 scending - and wrapped in a CompoundFetchedResultsController. This will maintain the ease of use
 in a UITableViewController, and the functionality provided by a NSFetchedResultsControllerDelegate.
 */
class CompoundFetchedResultsController<T: NSFetchRequestResult>: NSObject, NSFetchedResultsControllerDelegate {
    
    // The wrapperd controllers
    let controllers: [NSFetchedResultsController<T>]
    
    // A delegate to notify of changes. Each of the controllers' delegates are set to this class,
    // so that we can map the index paths in the notifications before forwarding to this delegate.
    var delegate: NSFetchedResultsControllerDelegate? {
        didSet { controllers.forEach{$0.delegate = self} }
    }
    
    init(controllers: [NSFetchedResultsController<T>]) { self.controllers = controllers }
    
    func performFetch() throws { controllers.forEach{try? $0.performFetch()} }
    
    var sections: [NSFetchedResultsSectionInfo]? {
        // To get the flattened sections array, we simply reduce-by-concatenation the inner controllers' sections arrays.
        get { return controllers.flatMap{$0.sections}.reduce([], +) }
    }
    
    func object(at indexPath: IndexPath) -> T {
        // Use the flattened sections array to get the object at the (flattened) index path
        return sections![indexPath.section].objects![indexPath.row] as! T
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Forward on the willChange notification
        delegate?.controllerWillChangeContent?(controller)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Forward on the didlChange notification
        delegate?.controllerDidChangeContent?(controller)
    }
    
    private func sectionOffset(forController controller: NSFetchedResultsController<NSFetchRequestResult>) -> Int {
        // Determine the index of the specified controller
        let controllerIndex = controllers.index(of: controller as! NSFetchedResultsController<T>)!
        
        // Count the number of sections present in all controllers up to (but not including) the supplied controller
        return controllers.prefix(upTo: controllerIndex).map{$0.sections!.count}.reduce(0, +)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        let sectionOffset = self.sectionOffset(forController: controller)
        
        // Index Paths should be adjusted by adding to the section offset to the section index
        func adjustIndexPath(_ indexPath: IndexPath?) -> IndexPath? {
            guard let indexPath = indexPath else { return nil }
            return IndexPath(row: indexPath.row, section: indexPath.section + sectionOffset)
        }
        
        // Forward on the notification with the adjusted index paths
        delegate?.controller?(controller, didChange: anObject, at: adjustIndexPath(indexPath), for: type, newIndexPath: adjustIndexPath(newIndexPath))
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let sectionOffset = self.sectionOffset(forController: controller)
        
        // Forward on the notification with the adjusted section index
        delegate?.controller?(controller, didChange: sectionInfo, atSectionIndex: sectionIndex + sectionOffset, for: type)
    }
}
