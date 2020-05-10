//
//  ViewController.swift
//  DollarGeneral
//
//  Created by Raphael DeFranco on 4/1/20.
//  Copyright © 2020 RaphaelDeFranco. All rights reserved.
//

import Cocoa

protocol StoreDetailViewControllerDelegate: AnyObject {
	func didUpdateStore()
}

class StoreDetailViewController: NSViewController {
	@IBOutlet var shopName: NSTextField!
	@IBOutlet var ownerName: NSTextField!
	@IBOutlet var location: NSTextField!
	@IBOutlet var type: NSPopUpButton!
	@IBOutlet var tableView: NSTableView!
	@IBOutlet var titleField: NSTextField!
	@IBOutlet var newItemField: NSTextField!
	@IBOutlet var saveButton: NSButton!
	@IBOutlet var copyButton: NSButton!
	@IBOutlet var removeButton: NSButton!
	@IBOutlet var addItemsButton: NSButton!
	@IBOutlet var rarityPopup: NSPopUpButton!
	@IBOutlet var pricePopup: NSPopUpButton!
	@IBOutlet var libraryButton: NSButton!

	private var store: Store = Store()
	private var itemDataSource = ItemTableViewDataSource()
	var delegate: StoreDetailViewControllerDelegate?

	override func viewDidLoad() {
		super.viewDidLoad()

		itemDataSource.delegate = self

		tableView.dataSource = itemDataSource
		tableView.delegate = itemDataSource

		removeButton.isEnabled = false
		set(enabled: false)
	}

	@IBAction func save(sender: Any) {
		update()

		if store.items.isEmpty {
			store.items = Library.default.random(with: store.shopType.itemTypes, count: Int.random(in: 10...50), rarity: nil, priceMod: Library.PriceMod.random)
		}

		save()
	}

	private func save() {
		do {
			try StoreCollection.default.save()
		} catch {
			let collection = StoreCollection(with: [store])
			try! collection.save()
		}

		refreshTableView()
		delegate?.didUpdateStore()
	}

	@IBAction func new(sender: Any) {
		configure(with: Store())
		StoreCollection.default.stores.append(store)

		set(enabled: true)

		delegate?.didUpdateStore()
	}

	@IBAction func copy(sender: Any) {
		let pasteboard = NSPasteboard.general
		pasteboard.clearContents()
		pasteboard.setData(store.display.data(using: .utf8), forType: .string)
	}

	@IBAction func addItems(sender: Any) {
		update()

		let numItems = newItemField.integerValue == 0 ? Int.random(in: 0...50) : newItemField.integerValue
		let itemRarity = ItemRarity.from(tag: rarityPopup.selectedItem?.tag ?? 0)
		let price = Library.PriceMod(rawValue: pricePopup.selectedItem?.tag ?? 0) ?? .standard

		let items = Library.default.random(with: store.shopType.itemTypes, count: numItems, rarity: itemRarity, priceMod: price)
		store.add(items: items)

		save()
	}

	@IBAction func remove(sender: Any) {
		guard tableView.selectedRow >= 0 else {
			return
		}
		store.items.remove(at: tableView.selectedRow)
		save()
		removeButton.isEnabled = false
	}
	@IBAction func didEdit(_ sender: NSView) {
		guard let textField = sender as? NSTextField else {
			return
		}

		let value = textField.stringValue
		let row = tableView.row(for: sender)
		let col = tableView.column(for: sender)

		guard row >= 0, col >= 0 else {
			return
		}

		let column = tableView.tableColumns[col]

		let id = column.identifier.rawValue
		let item = store.items[row]

		switch id {
		case "name":
			item.name = value
		case "price":
			let result = value.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789.").inverted)
			if let double = Double(result) {
				item.priceGP = double
			}
		case "source":
			item.source = value
		case "page":
			item.page = value
		case "description":
			item.description = value
		default:
			fatalError()
		}

		save()
	}

	private func update() {
		store.shopKeeper = ownerName.stringValue
		store.name = shopName.stringValue
		store.location = location.stringValue
		store.shopType = ShopType(rawValue: type.selectedItem!.title.lowercased())!
		titleField.stringValue = store.name
	}

	private func set(enabled: Bool) {
		ownerName.isEditable = enabled
		location.isEditable = enabled
		shopName.isEditable = enabled
		saveButton.isEnabled = enabled
		copyButton.isEnabled = enabled
		addItemsButton.isEnabled = enabled
		newItemField.isEditable = enabled
		type.isEnabled = enabled
		rarityPopup.isEnabled = enabled
		pricePopup.isEnabled = enabled
		libraryButton.isEnabled = enabled
	}

	func configure(with store: Store) {
		self.store = store
		titleField.stringValue = store.name.isEmpty ? "New Store" : store.name
		shopName.stringValue = store.name
		ownerName.stringValue = store.shopKeeper
		location.stringValue = store.location
		type.selectItem(withTag: store.shopType.tag)

		set(enabled: true)
		refreshTableView()
	}

	func refreshTableView() {
		itemDataSource.items = store.items
		tableView.reloadData()
	}

	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		guard let dest = segue.destinationController as? LibraryViewController else {
			return
		}

		dest.delegate = self
	}
}

extension StoreDetailViewController: ItemTableViewDataSourceDelegate {
	func didSelect(row: Int) {
		removeButton.isEnabled = row >= 0
	}
}

extension StoreDetailViewController: LibraryViewControllerDelegate {
	func add(item: Item) {
		store.add(items: [item])
		save()

		refreshTableView()
	}
}
