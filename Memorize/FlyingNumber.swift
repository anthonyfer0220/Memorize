//
//  FlyingNumber.swift
//  Memorize
//
//  Created by Tony Fernandez on 8/14/24.
//

import SwiftUI

struct FlyingNumber: View {
    let number: Int     // Number to be displayed
    
    @State private var offset: CGFloat = 0
    
    var body: some View {
        // Display number with flying animation if not zero, green and moving upwards if positive,
        // or red and moving downwards if negative
        if number != 0 {
            Text(number, format: .number.sign(strategy: .always()))
                .font(.largeTitle)
                .foregroundColor(number < 0 ? .red : .green)
                .shadow(color: .black, radius: 1.5, x: 1, y: 1)
                .offset(x: 0, y: offset)
                .opacity(offset != 0 ? 0 : 1)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.5)) {
                        offset = number < 0 ? 100 : -100
                    }
                }
                .onDisappear {
                    offset = 0
                }
        }
    }
}

#Preview {
    FlyingNumber(number: 5) // Test with a positive number (5)
}
