//
//  StoresViewController.swift
//  DollarGeneral
//
//  Created by Raphael DeFranco on 4/1/20.
//  Copyright © 2020 RaphaelDeFranco. All rights reserved.
//

import Foundation
import AppKit

class StoresSplitViewController: NSSplitViewController {
	override func viewDidLoad() {
		super.viewDidLoad()

		listView.delegate = self
		detailView.delegate = self
	}

	var detailView: StoreDetailViewController {
		for item in splitViewItems {
			if let detail = item.viewController as? StoreDetailViewController {
				return detail
			}
		}

		fatalError()
	}

	var listView: StoreListViewController {
		for item in splitViewItems {
			if let detail = item.viewController as? StoreListViewController {
				return detail
			}
		}

		fatalError()
	}
}

extension StoresSplitViewController: StoreListVCDelegate {
	func didSelect(store: Store) {
		detailView.configure(with: store)
	}
}

extension StoresSplitViewController: StoreDetailViewControllerDelegate {
	func didUpdateStore() {
		listView.refresh()
	}
}


