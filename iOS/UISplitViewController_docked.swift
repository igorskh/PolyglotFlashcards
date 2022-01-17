//
//  UISplitViewController_docked.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 15.01.22.
//

import SwiftUI

extension UISplitViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        preferredDisplayMode = .twoBesideSecondary
    }
}
