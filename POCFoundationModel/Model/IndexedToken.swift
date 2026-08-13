import Foundation

struct IndexedToken {
    var baseFileName: String
    var text: String
    var embedding: [Double]
    
    mutating func setEmbedding(_ vector: [Double]?) {
        embedding = vector ?? []
    }
}
