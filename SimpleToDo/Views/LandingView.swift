//
//  LandingView.swift
//  SimpleToDo
//
//  Created by Akhila Pasupunuri on 5/18/26.
//

import SwiftUI

struct LandingView: View {
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var showButton = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dark background
                Color(red: 0.08, green: 0.08, blue: 0.12)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Main heading with animation and glow
                    ZStack {
                        // Radial gradient spotlight glow
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.7, green: 0.5, blue: 1.0).opacity(0.8),
                                Color(red: 0.5, green: 0.3, blue: 0.9).opacity(0.5),
                                Color(red: 0.3, green: 0.2, blue: 0.6).opacity(0.2),
                                Color.clear,
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 250
                        )
                        .opacity(showTitle ? 1 : 0)
                        
                        VStack(alignment: .center, spacing: 24) {
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.95, green: 0.85, blue: 1.0),
                                    Color(red: 0.8, green: 0.85, blue: 0.98)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .mask(
                                Text("Welcome to One Focus")
                                    .font(.system(size: 42, weight: .bold, design: .default))
                                    .multilineTextAlignment(.center)
                            )
                            .shadow(color: Color(red: 0.7, green: 0.5, blue: 1.0).opacity(0.8), radius: 12, x: 0, y: 0)
                            .shadow(color: Color(red: 0.5, green: 0.3, blue: 0.9).opacity(0.6), radius: 24, x: 0, y: 0)
                            .shadow(color: Color(red: 0.7, green: 0.5, blue: 1.0).opacity(0.4), radius: 40, x: 0, y: 0)
                            .opacity(showTitle ? 1 : 0)
                            .offset(y: showTitle ? 0 : 20)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                            
                            // Subtitle with fade in animation and white glow
                            Text("The minimalist to do app, that helps you focus on what matters today.")
                                .font(.system(size: 16, weight: .regular, design: .default))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .shadow(color: Color.white.opacity(0.8), radius: 8, x: 0, y: 0)
                                .shadow(color: Color.white.opacity(0.5), radius: 16, x: 0, y: 0)
                                .shadow(color: Color.white.opacity(0.3), radius: 24, x: 0, y: 0)
                                .padding(.horizontal, 20)
                                .opacity(showSubtitle ? 1 : 0)
                                .transition(.opacity)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                    
                    // Next button with enhanced highlight
                    NavigationLink(destination: MainAppView()) {
                        Text("Next")
                            .font(.system(size: 16, weight: .semibold, design: .default))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.white.opacity(0.6), radius: 16, x: 0, y: 0)
                            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .opacity(showButton ? 1 : 0)
                    .offset(y: showButton ? 0 : 20)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                // Animate title first
                withAnimation(.easeOut(duration: 1.2)) {
                    showTitle = true
                }
                // Animate subtitle after 0.4s
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.easeOut(duration: 1.0)) {
                        showSubtitle = true
                    }
                }
                // Animate button after 0.8s
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.easeOut(duration: 1.0)) {
                        showButton = true
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    LandingView()
}