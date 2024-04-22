

import Foundation
struct Thumbnail : Codable {
    
	
    let id:  String?
	let domain : String?
	let basePath : String?
	let key : String?
	
	enum CodingKeys: String, CodingKey {
        case id = "id"
		case domain = "domain"
		case basePath = "basePath"
		case key = "key"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
		domain = try values.decodeIfPresent(String.self, forKey: .domain)
		basePath = try values.decodeIfPresent(String.self, forKey: .basePath)
		key = try values.decodeIfPresent(String.self, forKey: .key)
	}

}

extension Thumbnail {
    var downloadURL:  String {
        guard domain != nil else {return ""}
        guard basePath != nil else {return ""}
        guard key != nil else {return ""}
        return "\(self.domain!)/\(self.basePath!)/0/\(self.key!)"
    }
}
