//
//  ItemTableView.swift
//  DollarGeneral
//
//  Created by Raphael DeFranco on 4/14/20.
//  Copyright © 2020 RaphaelDeFranco. All rights reserved.
//

import Cocoa

protocol ItemTableViewDataSourceDelegate: AnyObject {
	func didSelect(row: Int)
}

class ItemTableViewDataSource: NSObject, NSTableViewDataSource, NSTableViewDelegate {
	var items = [Item]()
	weak var delegate: ItemTableViewDataSourceDelegate?

	func numberOfRows(in tableView: NSTableView) -> Int {
		return items.count
	}

	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		guard let id = tableColumn?.identifier.rawValue else {
			return nil
		}

		guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("cellView") , owner: nil) as? NSTableCellView else {

			return nil
		}

		let item = items[row]

		switch id {
		case "name":
			cell.textField?.stringValue = item.name
		case "price":
			cell.textField?.stringValue = "$\(item.priceGP)"
		case "source":
			cell.textField?.stringValue = item.source ?? ""
		case "page":
			cell.textField?.stringValue = item.page ?? ""
		case "description":
			cell.textField?.stringValue = item.description ?? ""
		default:
			fatalError()
		}

		return cell
	}

	func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
		delegate?.didSelect(row: row)
		return true
	}
}
