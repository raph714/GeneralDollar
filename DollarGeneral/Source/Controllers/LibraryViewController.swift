//
//  LibraryViewController.swift
//  DollarGeneral
//
//  Created by Raphael DeFranco on 4/14/20.
//  Copyright © 2020 RaphaelDeFranco. All rights reserved.
//

import Cocoa

protocol LibraryViewControllerDelegate: AnyObject {
	func add(item: Item)
}

class LibraryViewController: NSViewController {
	@IBOutlet weak var tableView: NSTableView!
	@IBOutlet weak var filterTextField: NSTextField!
	@IBOutlet weak var addButton: NSButton!

	weak var delegate: LibraryViewControllerDelegate!

	let allItems = Library.default.items
	var searchingItems = [Item]() {
		didSet {
			itemDataSource.items = searchingItems
			tableView.reloadData()
		}
	}

	var isSearching = false

	private var itemDataSource = ItemTableViewDataSource()

	override func viewDidLoad() {
		super.viewDidLoad()

		itemDataSource.items = Library.default.items

		tableView.dataSource = itemDataSource
		tableView.delegate = itemDataSource
	}

	@IBAction func addButtonHit(_ sender: Any) {
		guard tableView.selectedRow >= 0 else {
			return
		}

		let item: Item
		if isSearching {
			item = searchingItems[tableView.selectedRow]
		} else {
			item = allItems[tableView.selectedRow]
		}

		delegate.add(item: item)
	}
}

extension LibraryViewController: NSTextFieldDelegate {
	func controlTextDidChange(_ obj: Notification) {
		if filterTextField.stringValue.isEmpty {
			isSearching = false
			itemDataSource.items = allItems
			tableView.reloadData()
		} else {
			isSearching = true
			let searchVal = self.filterTextField.stringValue.lowercased()

			DispatchQueue.global().async { [weak self] in
				guard let self = self else {
					return
				}

				let filtered = self.allItems.filter { item -> Bool in
					if item.searchIndex.contains(searchVal) {
						return true
					} else {
						return false
					}
				}

				DispatchQueue.main.async {
					self.searchingItems = filtered
				}
			}

		}
	}
}
