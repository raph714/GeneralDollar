//
//  Store.swift
//  DollarGeneral
//
//  Created by Raphael DeFranco on 4/1/20.
//  Copyright © 2020 RaphaelDeFranco. All rights reserved.
//

import Foundation

enum ShopType: String, CaseIterable, Codable {
	case general
	case magic
	case weapons
	case armor
	case temple
	case potion

	var itemTypes: [ItemType] {
		switch self {
		case .general:
			return [.tool, .gemstone, .focus, .adventuringGear, .holySymbol, .mount, .poison, .vehicle, .generalGoods, .unknown]
		case .magic:
			return [.rings, .scrolls, .staffs, .rods, .wands, .gems, .wondrous]
		case .weapons:
			return [.weapons, .ammunition]
		case .armor:
			return [.armor, .shields]
		case .temple:
			return [.wondrous, .holySymbol, .focus, .staffs]
		case .potion:
			return [.potions]
		}
	}

	var tag: Int {
		switch self {
		case .general:
			return 0
		case .magic:
			return 1
		case .weapons:
			return 2
		case .armor:
			return 3
		case .temple:
			return 4
		case .potion:
			return 5
		}
	}
}

class StoreCollection: Codable {
	var stores: [Store]

	private static let fileName = "stores.json"

	static var `default`: StoreCollection = load()

	init(with stores: [Store]) {
		self.stores = stores
	}

	func save() throws {
		try JSONEncoder().save(encodable: self, to: StoreCollection.fileName)
	}

	static func load() -> StoreCollection {
		do {
			return try JSONDecoder().load(file: StoreCollection.fileName)
		} catch {
			return StoreCollection(with: [])
		}
	}
}

class Store: Codable {
	var location: String = ""
	var shopKeeper: String = ""
	var name: String = ""
	var items: [Item] = []
	var shopType: ShopType = .general

	init() {}

	init(location: String, shopKeeper: String, name: String, items: [Item], shopType: ShopType) {
		self.location = location
		self.shopKeeper = shopKeeper
		self.name = name
		self.items = items
		self.shopType = shopType
	}

	func add(items: [Item]) {
		self.items.append(contentsOf: items)
	}

	var display: String {
		var disp = "\(name), \(location)\nRun by: \(shopKeeper)\n"
		disp += "======================================================\n"
		for (index, item) in items.enumerated() {
			disp += "\(index). \(item.display)\n"
		}
		return disp
	}

	var listView: String {
		return "\(name), \(location) [\(items.count)]\n"
	}
}
