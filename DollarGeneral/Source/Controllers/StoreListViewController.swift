//
//  StoreListViewController.swift
//  DollarGeneral
//
//  Created by Raphael DeFranco on 4/3/20.
//  Copyright © 2020 RaphaelDeFranco. All rights reserved.
//

import Foundation
import AppKit

protocol StoreListVCDelegate: AnyObject {
	func didSelect(store: Store?)
}

class StoreListViewController: NSViewController {
	weak var delegate: StoreListVCDelegate?

	@IBOutlet var tableView: NSTableView!
	@IBOutlet var deleteButton: NSButton!

	override func viewDidLoad() {
		super.viewDidLoad()
		deleteButton.isEnabled = false
	}

	@IBAction func newStore(_ sender: Any) {
		let new = Store()
		StoreCollection.default.stores.append(new)

		refresh()
		let selectedStore = selectLast()
		delegate?.didSelect(store: selectedStore)
	}

	private func selectLast() -> Store? {
		let index = StoreCollection.default.stores.count - 1
		let indexes = IndexSet(integer: index)
		tableView.selectRowIndexes(indexes, byExtendingSelection: false)
		return StoreCollection.default.stores.last ?? nil
	}

	@IBAction func delete(_ sender: Any) {
		if tableView.selectedRow >= 0 {
			StoreCollection.default.stores.remove(at: tableView.selectedRow)
		}

		refresh()
		let selectedStore = selectLast()

		delegate?.didSelect(store: selectedStore)
	}

	func refresh() {
		tableView.reloadData()
	}
}

extension StoreListViewController: NSTableViewDelegate {
	func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
		let store = StoreCollection.default.stores[row]
		delegate?.didSelect(store: store)

		deleteButton.isEnabled = row >= 0
		return true
	}
}

extension StoreListViewController: NSTableViewDataSource {
	func numberOfRows(in tableView: NSTableView) -> Int {
		return StoreCollection.default.stores.count
	}

	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("whatever") , owner: nil) as? NSTableCellView {
		  cell.textField?.stringValue = StoreCollection.default.stores[row].listView
		  return cell
		}

		return nil
	}
}
