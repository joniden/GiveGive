//
//  ToyListView.swift
//  GiveGive
//
//  Created by Joanne Yager on 2023-11-06.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct ToyListView: View {
    
    @State var currentToyList: [Toy] = [Toy(), Toy()]
    
    var body: some View {
        ToyGridView(currentToyList: $currentToyList)
            .onAppear {
                listenToFirestore()
            }
    }
    
    func listenToFirestore() {
        let userId = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        
        db.collection("toys").order(by: "dateAdded", descending: false).whereField("currentOwner", isEqualTo: userId ?? "defaultId").addSnapshotListener { snapshot, err in
            guard let snapshot = snapshot else { return }
            
            if let err = err {
                print("Error getting document \(err)")
            } else {
                currentToyList.removeAll()
                for document in snapshot.documents {
                    let result = Result {
                        try document.data(as: Toy.self)
                    }
                    
                    switch result {
                    case .success(let toy):
                        currentToyList.append(toy)
                    case .failure(let error):
                        print("Error decoding journal entry \(error)")
                    }
                }
            }
        }
    }
}

struct ToyGridView: View {
    
    @Binding var currentToyList: [Toy]
    
    var body: some View {
        
        ScrollView{
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: UIDevice.current.userInterfaceIdiom == .pad ? 4 : 2), spacing: 10) {
                ForEach(currentToyList) { item in
                    
                    ToyThumbnailView(toy: item)
                    .padding(5)
                }
            }
            
        } .padding()
    }
}

struct ToyThumbnailView: View {
    
    var toy: Toy
    @State private var url: URL? = nil
    
    var body: some View {
        NavigationLink {
            ToyProfileView(toy: toy)
        } label: {
            ZStack {
                Rectangle()
                    .fill(.black)
                    .cornerRadius(10)
                    .aspectRatio(contentMode: .fit)
                
                if let urlString = toy.images.first, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .cornerRadius(10)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 150, height: 150)
                    }
                }
                
                /* Text(String(toy.id ?? "no id"))
                 .foregroundColor(.white)
                 .font(.title)*/
            }
        }
    }
}

// TODO: Make ViewModel for ToyListView with listenToFirestore in it
