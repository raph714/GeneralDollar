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
	func didSelect(store: Store)
}

class StoreListViewController: NSViewController {
	weak var delegate: StoreListVCDelegate?

	@IBOutlet var tableView: NSTableView!

	func refresh() {
		tableView.reloadData()
	}
}

extension StoreListViewController: NSTableViewDelegate {
	func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
		let store = StoreCollection.default.stores[row]
		delegate?.didSelect(store: store)
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
