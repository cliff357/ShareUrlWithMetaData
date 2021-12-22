//
//  ContentView.swift
//  ShareUrlWithMetaData
//
//  Created by Cliff Chan on 22/12/2021.
//

import SwiftUI
import LinkPresentation

struct ContentView: View {
	@State private var isSharePresented: Bool = false

	
    var body: some View {
		VStack{
			Button("Share app") {
					   self.isSharePresented = true
				   }
				   .sheet(isPresented: $isSharePresented, onDismiss: {
					   print("Dismiss")
				   }, content: {
					   ActivityViewController(activityItems: [URL(string: "https://www.apple.com")!])
				   })
			
			Text("Hello World")
				.fontWeight(.bold)
				.font(.title)
				.padding()
				.background(Color.purple)
				.cornerRadius(40)
				.foregroundColor(.white)
				.padding(10)
				.overlay(
					RoundedRectangle(cornerRadius: 40)
						.stroke(Color.purple, lineWidth: 5)
				)
			Button(action: {
				print("Delete tapped!")
			}) {
				HStack {
					Image(systemName: "trash")
						.font(.title)
					Text("Delete")
						.fontWeight(.semibold)
						.font(.title)
				}
			}
			.buttonStyle(GradientBackgroundStyle())
		}
		
    }
}

struct GradientBackgroundStyle: ButtonStyle {
	
	func makeBody(configuration: Self.Configuration) -> some View {
		configuration.label
			.frame(minWidth: 0, maxWidth: .infinity)
			.padding()
			.foregroundColor(.white)
			.background(LinearGradient(gradient: Gradient(colors: [Color("DarkGreen"), Color.blue]), startPoint: .leading, endPoint: .trailing))
			.cornerRadius(40)
			.padding(.horizontal, 20)
			.scaleEffect(configuration.isPressed ? 0.9 : 1.0)

	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct ActivityViewController: UIViewControllerRepresentable {

	var activityItems: [Any]
	var applicationActivities: [UIActivity]? = nil
	@Environment(\.presentationMode) var presentationMode

	func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
		let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
		controller.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
			self.presentationMode.wrappedValue.dismiss()
		}
		return controller
	}
	
	func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}

}
//
//var isFetchMetadataDynamic = true
//
//func shareAction(){
//	let urlString = "www.google.com"
//	var message = "I AM MESSAGE!!!!"
//	if let url = URL(string: urlString){
//		if isFetchMetadataDynamic {
//			//Fetch meta data from URL
////			if #available(iOS 13.0, *) {
//				fetchURLPreview(url: url)
////			} else {
////				self.shareByOlderMethod(message: message, url: url)
////			}
//		} else {
////			if #available(iOS 13.0, *) {
//				//Add metadata manually
//				let metaData = getMetadataForSharingManually(title: message, url: url, fileName: "fm_icon", fileType: "png")
//				shareURLWithMetadata(metaData: metaData)
////			} else {
////				shareByOlderMethod(message: message, url: url)
////			}
//		}
//	}
//}
//
//
//
//
//func shareURLWithMetadata(metaData: LPLinkMetadata) {
//	DispatchQueue.main.async {
//		let metadataItemSource = LinkPresentationItemSource(metaData: metaData)
//		let activity = UIActivityViewController(activityItems: [metadataItemSource], applicationActivities: [])
////		self.present(activity, animated: true)
//	}
//}
//
//
//func fetchURLPreview(url: URL) {
//	let metadataProvider = LPMetadataProvider()
//	metadataProvider.startFetchingMetadata(for: url) { (metaData, error) in
//		guard let data = metaData, error == nil else {
//			return
//		}
//
//		shareURLWithMetadata(metaData: data)
//	}
//}
//
//
//func getMetadataForSharingManually(title: String, url: URL, fileName: String, fileType: String) -> LPLinkMetadata {
//	let linkMetaData = LPLinkMetadata()
//	let path = Bundle.main.path(forResource: fileName, ofType: fileType)
//	linkMetaData.iconProvider = NSItemProvider(contentsOf: URL(fileURLWithPath: path ?? ""))
//	linkMetaData.originalURL = url
//	linkMetaData.title = title
//	return linkMetaData
//}
//
//
//
//class LinkPresentationItemSource: NSObject, UIActivityItemSource {
//	var linkMetaData = LPLinkMetadata()
//
//	//Prepare data to share
//	func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
//		return linkMetaData
//	}
//
//	//Placeholder for real data, we don't care in this example so just return a simple string
//	func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
//		return "Placeholder"
//	}
//
//	/// Return the data will be shared
//	/// - Parameters:
//	///   - activityType: Ex: mail, message, airdrop, etc..
//	func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
//		return linkMetaData.originalURL
//	}
//
//	init(metaData: LPLinkMetadata) {
//		self.linkMetaData = metaData
//	}
//}
//
