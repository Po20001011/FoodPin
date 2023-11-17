//
//  TutorialView.swift
//  FoodPin
//
//  
//

import SwiftUI

struct TutorialView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("hasViewedWalkthrough") var hasViewedWalkthrough: Bool = false
    
    @State private var currentPage = 0
    
    let pageHeadings = [ String(localized: "CREATE YOUR OWN FOOD GUIDE"), String(localized: "SHOW YOU THE LOCATION"), String(localized: "DISCOVER GREAT RESTAURANTS") ]
    let pageSubHeadings = [ String(localized: "Pin your favorite restaurants and create your own food guide"),
                            String(localized: "Search and locate your favorite restaurant on Maps"),
                            String(localized: "Find restaurants shared by your friends and other foodies")
                            ]
    let pageImages = [ "onboarding-1", "onboarding-2", "onboarding-3" ]
    
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .systemIndigo
        UIPageControl.appearance().pageIndicatorTintColor = .lightGray
    }
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(pageHeadings.indices, id: \.self) { index in
                    TutorialPage(image: pageImages[index], heading: pageHeadings[index], subHeading: pageSubHeadings[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .automatic))
            .animation(.default, value: currentPage)
            
            VStack(spacing: 20) {
                Button(action: {
                    if currentPage < pageHeadings.count - 1 {
                        currentPage += 1
                    } else {
                        hasViewedWalkthrough = true
                        dismiss()
                    }
                }) {
                    Text(currentPage == pageHeadings.count - 1 ? String(localized: "GET STARTED") : String(localized: "NEXT"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .padding(.horizontal, 50)
                        .background(Color(.systemIndigo))
                        .cornerRadius(25)
                }

                if currentPage < pageHeadings.count - 1 {
                    
                    Button(action: {
                        hasViewedWalkthrough = true
                        dismiss()
                    }) {
                        
                        Text(String(localized: "Skip"))
                            .font(.headline)
                            .foregroundColor(Color(.darkGray))
                        
                    }
                }
            }
            .padding(.bottom)

        }
        
    }
}

struct TutorialPage: View {
    
    let image: String
    let heading: String
    let subHeading: String
    
    var body: some View {
        VStack(spacing: 70) {
            Image(image)
                .resizable()
                .scaledToFit()
            
            VStack(spacing: 10) {
                Text(heading)
                    .font(.headline)
                
                Text(subHeading)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding(.top)
    }
}

struct TutorialView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialView()
        
        TutorialPage(image: "onboarding-1", heading: "CREATE YOUR OWN FOOD GUIDE", subHeading: "Pin your favorite restaurants and create your own food guide")
                .previewLayout(.sizeThatFits)
                .previewDisplayName("TutorialPage")
    }
}

