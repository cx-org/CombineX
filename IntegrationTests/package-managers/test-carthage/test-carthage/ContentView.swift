//
// ContentView.swift
//
//
// Created by Quentin Jin on 2021/5/31.
//


import SwiftUI
import CombineX
import CXFoundation

private var cancellable: AnyCancellable?

struct ContentView: View {
    @State
    private var count = 1
    
    @State
    private var isRunning = false
    
    var body: some View {
        VStack {
            Text("\(count)")
            Button(isRunning ? "STOP" : "START") {
                defer {
                    isRunning.toggle()
                }

                if isRunning {
                    cancellable?.cancel()
                } else {
                    cancellable = CXWrappers.Timer
                        .publish(
                            every: 1,
                            on: .main,
                            in: .common
                        )
                        .autoconnect()
                        .sink(receiveValue: { _ in
                            count += 1
                        })
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
