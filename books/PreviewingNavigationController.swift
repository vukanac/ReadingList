//
//  PreviewingNavigationController.swift
//  books
//
//  Created by Andrew Bennet on 11/10/2016.
//  Copyright © 2016 Andrew Bennet. All rights reserved.
//

import UIKit

class PreviewingNavigationController: UINavigationController {

    override var previewActionItems: [UIPreviewActionItem] {
        return self.topViewController!.previewActionItems
    }
}