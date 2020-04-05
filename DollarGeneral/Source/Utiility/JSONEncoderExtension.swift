//
//  JSONEncoderExtension.swift
//  DollarGeneral
//
//  Created by Raphael DeFranco on 4/3/20.
//  Copyright © 2020 RaphaelDeFranco. All rights reserved.
//

import Foundation

enum EncoderError: Error {
	case documentDirectoryNotFound
}

extension JSONEncoder {
	@discardableResult
	func save<T: Encodable>(encodable: T, to file: String) throws -> URL {
		outputFormatting = .prettyPrinted
		let json = try self.encode(encodable)

		guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
			throw EncoderError.documentDirectoryNotFound
		}

		let fileUrl = documentDirectoryUrl.appendingPathComponent(file)
		print(fileUrl)
		try json.write(to: fileUrl)
		return fileUrl
	}
}
