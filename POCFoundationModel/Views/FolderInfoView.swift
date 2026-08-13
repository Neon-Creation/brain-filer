import SwiftUI

struct ArchiveContainer: View {
    var archiveName: String
    
    init(_ archiveName: String) {
        self.archiveName = archiveName
    }
    
    var body: some View {
        HStack {
            Text(archiveName)
            Spacer()
            Image(systemName: "chevron.right")
        }
    }
}

struct FolderInfoView: View {
    var folderTitle: String
    
    @State private var viewArchive: Bool = false
    @State private var selectedArchive: String = ""
    
    var archivesInFolder: [String] {
        return ArchiveViewModel.folderLink[folderTitle] ?? []
    }
        
    var body: some View {
        VStack {
            List {
                ForEach(archivesInFolder, id: \.self) { archive in
                    NavigationLink(archive) {
                        ArchiveInfo(fileName: archive)
                    }
                }
            }
        }
        .navigationTitle(folderTitle)
    }
}
