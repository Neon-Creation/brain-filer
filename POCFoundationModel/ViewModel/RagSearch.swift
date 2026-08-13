import Observation
import FoundationModels
import NaturalLanguage

@Observable
class RagSearch {
    var indexedTokens: [IndexedToken] = []
        
    func contextFromFiles(userPrompt: String)  -> (fileNames: String, context: String) {
        var content = ""
        var contentFileName = ""
                
        let relations = embeddingContent(userPrompt: userPrompt)
        let sortedRelations = relations.sorted(by: {$0.distance < $1.distance}).prefix(5)
                
        for item in sortedRelations {
            content += "\(item.token.text)\n"
            contentFileName += "\(item.token.baseFileName), "
        }
         
        return (fileNames: contentFileName, context: content)
    }
    
    func tokenizeAllFiles(archives: [String : [String]]) {
        let categorysWithArchives = ArchiveViewModel.validFolders()
        
        for category in categorysWithArchives {
            let fileNames = archives[category]
            
            for file in fileNames ?? [] {
                let content = ArchiveViewModel.contentFromMDFile(file).cleanMd
                tokenizeContent(fileName: file, content: content)
            }
        }
    }
    
    private func embeddingContent(userPrompt: String) -> [(token: IndexedToken, distance: Double)] {
        var tokenDistanceRelation: [(token: IndexedToken, distance: Double)] = []
        
        if let embedding = NLEmbedding.sentenceEmbedding(for: .portuguese, revision: 2) {
            for index in indexedTokens.indices {
                let sentence = indexedTokens[index].text
                
                if let vector = embedding.vector(for: sentence) {
                    indexedTokens[index].setEmbedding(vector)
                }
                
                let distance = embedding.distance(between: sentence, and: userPrompt, distanceType: .cosine)
                let relation = (token: indexedTokens[index], distance: distance)
                
                tokenDistanceRelation.append(relation)
            }
        }
        
        return tokenDistanceRelation
    }
    
    func tokenizeContent(fileName: String, content: String) {
        if indexedTokens.contains(where: {$0.baseFileName == fileName}) {
            return 
        }
        
        var conInteraction: Int = 0
        var context = ""
                
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = content
        
        tokenizer.enumerateTokens(in: content.startIndex..<content.endIndex) { tokenRange, _  in
            let tokenizedContent = String(content[tokenRange])
            context += tokenizedContent
            conInteraction += 1
            print("Chunck: \(context) \n")
            
            if conInteraction == 2 {
                let indexToken = IndexedToken(
                    baseFileName: fileName,
                    text: context,
                    embedding: [])
                
                indexedTokens.append(indexToken)
                
                context = ""
            }
            
            return true
        }
        
    }
}
