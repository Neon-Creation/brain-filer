import Observation
import SwiftUI
import FoundationModels
import Foundation

@Observable
class ArchiveViewModel {
    var RAGSearch: RagSearch = RagSearch()
    
    static var folderLink: [String:[String]] = [
        "Animais": [],
        "Natureza": [],
        "Gastronomia": [],
        "Ciência": [],
        "Casa": [],
        "Saúde": [],
        "Tecnologia": [],
        "Finanças": []
    ]
    
    func respondFinalUser(prompt: String) async -> String {
        let content = RAGSearch.contextFromFiles(userPrompt: prompt)
        
        let session = LanguageModelSession(instructions: "Atue como um pesquisador. A sua tarefa é responder à pergunta do usuário baseando-se nos trechos de documentos fornecidos abaixo")
        
        let prompt =
        """
        Regras estritas:
        - Use suas o conteúdo apensas para complementar sua resposta, se não tiver, responda misture o que for útil com o que você sabe"
        - Complemente sua respota com as informações dos arquivos.
        - Sempre cite a fonte (nome do arquivo) de onde você extraiu a informação no final da sua resposta. Não invente fontes, sempre o nome do arquivo, se não achar coloque fonte própria.
        - Se existir varias fontes diferentes, cite a que possui mais vezes

        CONTEÚDO DOS ARQUIVOS ENCONTRADOS:
        ---
        \(content.context)
        ---
        
        FONTE DOS ARQUIVOS
        ---
        \(content.fileNames)
        ---

        PERGUNTA DO USUÁRIO: 
        \(prompt)
        """
        
        do {
            let response = try await session.respond(to: prompt)
            return response.content
        } catch {
            print("\(error.localizedDescription)")
        }
        
        return ""
    }
    
    func categorizeFiles() async {
        let files = handleFilesBaseNames()
        
        do {
            for file in files {
                let contentFile = ArchiveViewModel.contentFromMDFile(file).mdText.prefix(800)
                let session = LanguageModelSession()
                
                let existingCategory = ArchiveViewModel.folderLink.keys.joined(separator: ", ")
                
                let prompt = """
                Você é um classificador de textos. Sua tarefa é categorizar o texto abaixo usando EXATAMENTE UMA PALAVRA.

                --- INÍCIO DO TEXTO ---
                \(contentFile)
                --- FIM DO TEXTO ---

                Categorias Existentes: \(existingCategory)

                Regras de Decisão:
                1. Tente encaixar o texto em uma das Categorias Existentes. (Ex: Textos sobre cachorros vão para "Animais", não invente "Biologia" ou "Pets").
                2. SOMENTE se o assunto for completamente diferente de TODAS as opções existentes, crie UMA NOVA CATEGORIA.
                3. Se precisar criar, crie uma palavra AMPLA (Ex: use "Esportes" em vez de "Natação").

                Regra de Formato:
                Retorne APENAS a palavra da categoria (escolhida ou criada). Sem pontuação, sem listas e sem explicações.

                Categoria:
                """
                
                let response = try await session.respond(to: prompt).content
                
                if let category = response.components(separatedBy: .whitespacesAndNewlines).first?.capitalized {
                    print(category)
                    
                    if ArchiveViewModel.folderLink[category] == nil {
                        ArchiveViewModel.folderLink[category] = [file]
                    } else {
                        ArchiveViewModel.folderLink[category]?.append(file)
                    }
                }
            }
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    static func validFolders() -> [String] {
        var categorysWithArchives: [String] = []
        
        for key in folderLink.keys {
            if !(folderLink[key] ?? []).isEmpty {
                categorysWithArchives.append(key)
            }
        }
        
        return categorysWithArchives
    }
    
    static func contentFromMDFile(_ fileName: String) -> (mdText: String, cleanMd: String) {
        guard let file = Bundle.main.url(forResource: fileName, withExtension: "md")
        else {
            return ("Error", "Error")
        }
        
        do {
            // STRING PARA TOKENIZAR
            let rawString = try String(contentsOf: file, encoding: .utf8)
                    
            let stringWithoutSymbols = rawString
                .replacingOccurrences(of: #"[*_`#\-+>]"#, with: "", options: .regularExpression)
            
            let stringWithoutSpaces = stringWithoutSymbols
                .components(separatedBy: .newlines)
                .filter {!$0.isEmpty}
                .joined(separator: "\n")

            let newString = stringWithoutSpaces
                .components(separatedBy: .newlines)
                .map {$0.trimmingCharacters(in: .whitespacesAndNewlines)}
                .filter {!$0.isEmpty}
                .joined(separator: " ")
            
            // PARA AMOSTRAGEM NA VIEW
            let allMdText = try String(AttributedString(
                contentsOf: file,
                options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnly)
            ).characters)
            
            return (allMdText, newString)
        } catch {
            print("\(error.localizedDescription)")
        }
        
        return ("", "")
    }
    
    private func handleFilesBaseNames() -> [String] {
        let bundle = Bundle.main.bundlePath
        
        do {
            let allFiles = try FileManager.default.contentsOfDirectory(atPath: bundle)
            let mdFiles = allFiles.filter( {$0.hasSuffix("md")} )
            let baseNameFiles = mdFiles.map { $0.replacingOccurrences(of: ".md", with: "") }
            
            return baseNameFiles
        } catch {
            print("\(error.localizedDescription)")
        }
        
        return []
    }
    
}
