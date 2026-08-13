import SwiftUI
import FoundationModels
import Playgrounds

struct FolderContainer: View {
    var folderName: String
    
    init(_ folderName: String) {
        self.folderName = folderName
    }
    
    var body: some View {
        VStack (spacing: 8) {
            Image(systemName: "folder.fill")
            
            Text(folderName)
                .font(.caption)
                .lineLimit(1)
        }
        .font(.title2)
        .foregroundStyle(.white)
        .padding(.horizontal, 36)
        .padding(.vertical, 16)
        .glassEffect(
            .regular.tint(.blue).interactive(),
            in: .rect(cornerRadius: 10)
        )
    }
}

struct ContentView: View {
    @State private var openFolder: Bool = false
    @State private var selectedFolder: String = ""
    
    @State private var userPrompt: String = ""
    @State private var userResponse: String = ""
    
    @State private var isLoading: Bool = false
    @State private var isResponseLoading: Bool = false
    
    @Environment(ArchiveViewModel.self) var archVm
    
    var existingFolders: [String] {
        return ArchiveViewModel.validFolders()
    }
    
    let col = Array(
        repeating: GridItem(.flexible()),
        count: 3
    )
    
    var body: some View {
        VStack {
            if !isLoading {
                ScrollView {
                    LazyVGrid(columns: col, spacing: 14) {
                        ForEach(existingFolders, id: \.self) { folder in
                            FolderContainer(folder)
                                .onTapGesture {
                                    selectedFolder = folder
                                    openFolder = true
                                }
                        }
                    }
                    
                    Spacer()
                    
                    if !existingFolders.isEmpty {
                        VStack (spacing: 20) {
                            TextField("Seu prompt", text: $userPrompt)
                                .textFieldStyle(.roundedBorder)
                                .cornerRadius(20)
                                .border(.black)
                            Button("Enviar prompt") {
                                getResponse()
                            }
                            .tint(.blue)
                            .buttonStyle(.glassProminent)
                        }
                        .padding()
                    }
                    
                    if !isResponseLoading {
                        Text(userResponse)
                            .font(.title2)
                            .padding()
                    } else {
                        ProgressView("Pesquisando...")
                    }
                }
            } else {
                ProgressView("Categorizando documentos...")
            }
        }
        .padding(.top, 20)
        .toolbar {
            if existingFolders.isEmpty {
                ToolbarItem {
                    Button("Adicionar", systemImage: "plus") {
                        getFolders()
                    }
                    .foregroundStyle(.white)
                    .tint(.blue)
                    .buttonStyle(.glassProminent)
                }
            }
        }
        .navigationTitle("Pastas")
        .navigationDestination(isPresented: $openFolder) {
            FolderInfoView(folderTitle: selectedFolder)
        }
        .onAppear {
            let content = ArchiveViewModel.contentFromMDFile("an_domestic")
            print(content.cleanMd)
        }
    }
}

extension ContentView {
    func getResponse() {
        isResponseLoading = true
        
        Task {
            userResponse = await archVm.respondFinalUser(prompt: userPrompt)
            isResponseLoading = false
        }
    }
    
    func getFolders() {
        isLoading = true
        
        Task {
            await archVm.categorizeFiles()
            archVm.RAGSearch.tokenizeAllFiles(archives: ArchiveViewModel.folderLink)
            isLoading = false
        }
    }
}

#Preview {
    ContentView()
        .environment(ArchiveViewModel())
}
