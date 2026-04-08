import Foundation

struct Credentials {
    var username: String
    var password: String
    var serverURL: String
    var serverID: String
    var accountID: String?
    var refreshToken: String?
    var refreshExpiresAt: Int?
}
