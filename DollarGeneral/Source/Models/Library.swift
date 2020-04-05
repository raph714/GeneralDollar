//
//  Library.swift
//  DollarGeneral
//
//  Created by Raphael DeFranco on 4/3/20.
//  Copyright © 2020 RaphaelDeFranco. All rights reserved.
//

import Foundation

class Library {
	enum PriceMod: Int {
		case standard
		case expensive
		case cheap

		var doubleValue: Double {
			switch self {
			case .standard:
				return 1.04
			case .expensive:
				return 1.27
			case .cheap:
				return 0.77
			}
		}

		static var random: PriceMod {
			return PriceMod(rawValue: Int.random(in: 0...2)) ?? .standard
		}
	}

	var items: [Item]

	init(items: [Item]) {
		self.items = items
	}

	static var `default`: Library = {
		let items: [Item] = try! JSONDecoder().load(file: "library.json")
		return Library(items: items)
	}()

	func random(with types: [ItemType], count: Int, rarity: ItemRarity?, priceMod: PriceMod) -> [Item] {
		let filtered = items.filter({ types.contains($0.type) })

		var items = [Item]()

		while items.count < count {
			let r = rarity ?? ItemRarity.random

			let itemsWithRarity = filtered.filter({ $0.rarity == r })

			if itemsWithRarity.count == 0 {
				if rarity != nil {
					break
				}
				print("no items found")
				continue
			}

			let index = Int.random(in: 0...(itemsWithRarity.count - 1))

			let item = itemsWithRarity[index]
			let moddedPrice = ceil(item.priceGP * priceMod.doubleValue * 100) / 100
			item.priceGP = moddedPrice

			items.append(item)
		}

		return items
	}
}
