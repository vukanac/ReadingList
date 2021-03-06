import Foundation
import UIKit
import DZNEmptyDataSet
import Eureka
import ImageRow

func duplicateBookAlertController(goToExistingBook: @escaping () -> Void, cancel: @escaping () -> Void) -> UIAlertController {

    let alert = UIAlertController(title: "Book Already Added", message: "A book with the same ISBN or Google Books ID has already been added to your reading list.", preferredStyle: .alert)

    // "Go To Existing Book" option - dismiss the provided ViewController (if there is one), and then simulate the book selection
    alert.addAction(UIAlertAction(title: "Go To Existing Book", style: .default) { _ in
        goToExistingBook()
    })

    // "Cancel" should just envoke the callback
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
        cancel()
    })

    return alert
}

class StandardEmptyDataset {

    static func title(withText text: String) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: [.font: UIFont.gillSans(ofSize: 32),
                                                             .foregroundColor: UserDefaults.standard[.theme].titleTextColor])
    }

    static func description(withMarkdownText markdownText: String) -> NSAttributedString {
        let bodyFont = UIFont.gillSans(forTextStyle: .title2)
        let boldFont = UIFont.gillSansSemiBold(forTextStyle: .title2)

        let markedUpString = NSAttributedString.createFromMarkdown(markdownText, font: bodyFont, boldFont: boldFont)
        markedUpString.addAttribute(.foregroundColor, value: UserDefaults.standard[.theme].subtitleTextColor, range: NSRange(location: 0, length: markedUpString.string.count))
        return markedUpString
    }
}
