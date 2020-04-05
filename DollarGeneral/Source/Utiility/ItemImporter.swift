//
//  ItemImporter.swift
//  DollarGeneral
//
//  Created by Raphael DeFranco on 4/3/20.
//  Copyright © 2020 RaphaelDeFranco. All rights reserved.
//

import Foundation

class ItemImporter {
	enum ImportType {
		case magic
		case general
	}

	static func generateLibararyJson() -> URL? {
		let magicItems = ItemImporter.loadItems(file: "D&D Magical Item Prices - Magic Items", type: .magic)
		let general = ItemImporter.loadItems(file: "D&D Magical Item Prices - Mundane Items", type: .general)

		var allItems = magicItems
		allItems.append(contentsOf: general)

		do {
			let url = try JSONEncoder().save(encodable: allItems, to: "library.json")
			return url
		} catch {
			print(String(describing: error))
			return nil
		}
	}

	static func loadItems(file named: String, type: ImportType) -> [Item] {
		guard let filePath = Bundle.main.path(forResource: named, ofType: "csv") else {
			return []
		}

		do {
			let contents = try String(contentsOf: URL(fileURLWithPath: filePath))
			let rows = contents.components(separatedBy: "\n")

			var items = [Item]()

			//toss out the first row
			for (index, row) in rows.enumerated() {
				if index == 0 {
					continue
				}

				switch type {
				case .magic:
					if let item = magicItem(from: row) {
						items.append(item)
					}
				case .general:
					if let item = mundane(from: row) {
						items.append(item)
					}
				}
			}

			return items
		} catch {
			print(String(describing: error))
			return []
		}
	}

	static func magicItem(from string: String) -> Item? {
		let cleaned = string.replacingOccurrences(of: "\"", with: "")
		let cleaned2 = cleaned.replacingOccurrences(of: "\\", with: "")
		let items = cleaned2.components(separatedBy: ",")

		guard items.count > 7 else {
			return nil
		}

		let name = items[0]
		let sanePrice = Double(items[1])
		let dmgPrice = Double(items[2])
		let priceRange = items[3]
		let rarity = ItemRarity(rawValue: items[4].lowercased())
		let source = items[5]
		let page = items[6]
		var type = ItemType(rawValue: items[7].lowercased())

		if type == nil {
			let raw = items[7].lowercased()
			if raw.contains("wondrous item") {
				type = .wondrous
			} else if raw.contains("ring") {
				type = .rings
			} else if raw.contains("potion") {
				type = .potions
			} else {
				type = .unknown
			}
		}

		var finalPrice: Double = 0
		if let sane = sanePrice {
			finalPrice = sane
		} else if let price = dmgPrice {
			finalPrice = price
		} else {
			let range = priceRange.replacingOccurrences(of: "+", with: "").components(separatedBy: "-")
			if range.count == 2, let start = Int(range[0]), let end = Int(range[1]) {
				let rand = Int.random(in: start...end)
				finalPrice = Double(rand)
			} else if range.count == 1, let price = Double(range[0]) {
				finalPrice = price
			} else {
				return nil
			}
		}

		let item = Item(name: name, priceGP: finalPrice, rarity: rarity!, source: source, page: page, type: type!, description: nil)
		return item
	}

	static func mundane(from string: String) -> Item? {
		let cleaned = string.replacingOccurrences(of: "\"", with: "")
		let cleaned2 = cleaned.replacingOccurrences(of: "\\", with: "")
		let items = cleaned2.components(separatedBy: ",")

		let name = items[0]
		guard let sanePrice = Double(items[1]) else {
			return nil
		}
		var type = ItemType(rawValue: items[4].lowercased())

		if type == nil {
			let raw = items[4].lowercased()
			if raw.contains("weapon") {
				type = .weapons
			} else if raw.contains("armor") {
				type = .armor
			} else if raw.contains("shield") {
				type = .shields
			} else if raw.contains("focus") {
				type = .focus
			} else if raw.contains("vehicle") {
				type = .vehicle
			} else if raw.contains("potion") {
				type = .potions
			} else {
				type = .generalGoods
			}
		}

		let item = Item(name: name, priceGP: sanePrice, rarity: .common, source: nil, page: nil, type: type!, description: nil)
		return item
	}
}
