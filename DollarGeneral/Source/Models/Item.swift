//
//  Item.swift
//  DollarGeneral
//
//  Created by Raphael DeFranco on 4/3/20.
//  Copyright © 2020 RaphaelDeFranco. All rights reserved.
//

import Foundation

enum ItemType: String, Codable {
	case armor
	case weapons
	case wondrous = "wonderous items"
	case ammunition
	case potions = "potions & oils"
	case rings
	case shields
	case scrolls = "spell scrolls"
	case staffs
	case rods
	case wands
	case gems = "spell gems"

	//general stuff
	case tool
	case gemstone
	case focus
	case adventuringGear = "adventuring gear"
	case holySymbol = "holy symbol"
	case mount
	case poison
	case vehicle
	case generalGoods
	case unknown
}

enum ItemRarity: String, Codable {
	case common
	case uncommon
	case rare
	case veryRare = "very rare"
	case legendary
	case artifact

	case varies

	static var weights: [ItemRarity: Int] {
		return [.common: 750, .uncommon: 150, .rare: 30, .veryRare: 10, .legendary: 3, .artifact: 1, .varies: 25]
	}

	static var random: ItemRarity {
		//sum the values
		let sum = weights.values.reduce(0) { result, next -> Int in
			return result + next
		}

		let random = Int.random(in: 1...sum)

		var currentCount = 0
		for (key, value) in weights {
			currentCount += value

			if currentCount >= random {
				return key
			}
		}

		fatalError()
	}

	static func from(tag: Int) -> ItemRarity? {
		switch tag {
		case 0:
			return .common
		case 1:
			return .uncommon
		case 2:
			return .rare
		case 3:
			return .veryRare
		case 4:
			return .legendary
		case 5:
			return .artifact
		case 6:
			return .varies
		default:
			return nil
		}
	}
}

class Item: Codable {
	var name: String
	var priceGP: Double
	var rarity: ItemRarity

	var source: String?
	var page: String?
	var type: ItemType

	var description: String?

	init(name: String, priceGP: Double, rarity: ItemRarity, source: String?, page: String?, type: ItemType, description: String?) {
		self.name = name
		self.priceGP = priceGP
		self.rarity = rarity
		self.source = source
		self.page = page
		self.type = type
		self.description = description
	}

	var sourceDisplay: String {
		if let source = source, let page = page {
			return "\(source) p.\(page)"
		}
		return ""
	}

	var display: String {
		var desc = ""
		desc += "$\(String(format: "%.2f", priceGP))"

		let charCount = 10 - desc.count
		for _ in 0...charCount {
			desc += " "
		}

		desc += "\(name)"

		if !sourceDisplay.isEmpty {
			desc += "; \(sourceDisplay)"
		}

		if let description = description {
			desc += ", \(description)"
		}

		return desc
	}

	var searchIndex: String {
		var index = display

		index += " \(type.rawValue) "
		index += " \(rarity.rawValue) "

		return index.lowercased()
	}
}
