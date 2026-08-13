import SwiftUI
import Textual

struct ArchiveInfo: View {
    @Environment(ArchiveViewModel.self) var archVm
    
    var fileName: String
    
    var convertedText: String {
        ArchiveViewModel.contentFromMDFile(fileName).mdText
    }
    
    var body: some View {
        ScrollView {
            VStack {
                StructuredText(markdown: convertedText)
            }
            .padding()
        }
        .navigationTitle(fileName)
    }
    
    
}

#Preview {
    ArchiveInfo(fileName: "an_studies")
}
