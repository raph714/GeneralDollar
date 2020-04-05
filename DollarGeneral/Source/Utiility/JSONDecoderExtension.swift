//
//  JSONDecoderExtension.swift
//  DollarGeneral
//
//  Created by Raphael DeFranco on 4/3/20.
//  Copyright © 2020 RaphaelDeFranco. All rights reserved.
//

import Foundation

extension JSONDecoder {
	func load<T: Decodable>(file: String) throws -> T {
		guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
			throw EncoderError.documentDirectoryNotFound
		}

		let fileUrl = documentDirectoryUrl.appendingPathComponent(file)

		do {
			let data = try Data(contentsOf: fileUrl)
			let json = try decode(T.self, from: data)
			return json
		} catch {
			if let fileUrl = Bundle.main.url(forResource: file, withExtension: nil) {
				let data = try Data(contentsOf: fileUrl)
				return try self.decode(T.self, from: data)
			}

			throw error
		}
	}
}
