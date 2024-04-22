
import Foundation

struct APIResponse : Codable {
	
	let thumbnail : Thumbnail?
	
	enum CodingKeys: String, CodingKey {
		case thumbnail = "thumbnail"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		thumbnail = try values.decodeIfPresent(Thumbnail.self, forKey: .thumbnail)
	}

}
