//
//  ContentView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 9/16/24.
//

import SwiftUI
import RealityKit
import UIKit

enum AuthState {
    case signIn
    case signUp
}

struct CameraView: UIViewControllerRepresentable {
    
    @Binding var isPresented: Bool
    @Binding var image: UIImage?
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraView
        
        init(parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}


struct SignInView: View {
    @Binding var authState: AuthState
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSignedIn: Bool = false
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                Text("Sign In")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                
                Button(action: {
                    signIn()
                }) {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                Button(action: {
                    authState = .signUp
                }) {
                    Text("Don't have an account? Sign Up")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                .padding(.top, 10)
            }
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(20)
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showCamera) {
            CameraView(isPresented: $showCamera, image: $capturedImage)
        }
    }
    
    func signIn() {
        if !email.isEmpty && !password.isEmpty {
            isSignedIn = true
            showCamera = true // Open the camera when signing in
        }
    }
}

struct SignUpView: View {
    @Binding var authState: AuthState
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirm_password = ""
    @State private var username: String = ""
    @State private var isSignedUp: Bool = false
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    
    var body: some View {
        VStack {
            Spacer()
            VStack (spacing: 16) {
                Text("Sign Up")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                
                TextField("Email", text:$email)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                
                TextField("Username", text:$username)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                
                SecureField("Confirm Password", text: $confirm_password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                
                Button(action: {
                    signUp()
                }) {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    authState = .signIn
                }) {
                    Text("Already have an account? Sign In")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                .padding(.top, 10)
            }
            .padding()
            .background(Color.white.opacity(0.5))
            .cornerRadius(20)
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showCamera) {
            CameraView(isPresented: $showCamera, image: $capturedImage)
        }
    }
    
    func signUp() {
        if !email.isEmpty && !username.isEmpty && !password.isEmpty && !confirm_password.isEmpty {
            isSignedUp = true
            showCamera = true // Open the camera when signing up
        }
    }
}


struct ContentView : View {
    
    @State private var authState: AuthState = .signIn
    
    var body: some View {
        ZStack {
            ARViewContainer().edgesIgnoringSafeArea(.all)

            switch authState {
            case .signIn:
                SignInView(authState: $authState)
            case .signUp:
                SignUpView(authState: $authState)

            }
        }
        
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)

        // Create a cube model
        let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
        let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
        let model = ModelEntity(mesh: mesh, materials: [material])
        model.transform.translation.y = 0.05

        // Create horizontal plane anchor for the content
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        anchor.children.append(model)

        // Add the horizontal plane anchor to the scene
        arView.scene.anchors.append(anchor)

        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

#Preview {
    ContentView()
}
