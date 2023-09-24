//
//  AmountView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 9/15/23.
//

import BitcoinUI
import SwiftUI

struct AmountView: View {
    @Bindable var viewModel: AmountViewModel
    @State var numpadAmount = "0"
    @State private var isSendPresented = false

    var body: some View {

        ZStack {
            Color(uiColor: .systemBackground)

            VStack(spacing: 50) {
                Spacer()
                VStack(spacing: 4) {
                    Text("\(numpadAmount.formattedWithSeparator) sats")
                        .textStyle(BitcoinTitle1())
                    if let balance = viewModel.balanceTotal {
                        HStack(spacing: 2) {
                            Text(balance.delimiter)
                            Text("sats available")
                        }
                        .fontWeight(.semibold)
                        .font(.caption)
                    }
                }

                GeometryReader { geometry in
                    let buttonSize = geometry.size.width / 4
                    VStack(spacing: buttonSize / 10) {
                        numpadRow(["1", "2", "3"], buttonSize: buttonSize)
                        numpadRow(["4", "5", "6"], buttonSize: buttonSize)
                        numpadRow(["7", "8", "9"], buttonSize: buttonSize)
                        numpadRow([" ", "0", "<"], buttonSize: buttonSize)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 300)

                Spacer()

                Button {
                    isSendPresented = true
                } label: {
                    Label(
                        title: { Text("Next") },
                        icon: { Image(systemName: "arrow.right") }
                    )
                    .labelStyle(.iconOnly)
                }
                .buttonStyle(BitcoinOutlined(width: 100, isCapsule: true))

            }
            .padding()
            .task {
                viewModel.getBalance()
            }
            .sheet(
                isPresented: $isSendPresented
            ) {
                AddressView(amount: numpadAmount)
            }

        }
        .onChange(of: isSendPresented) {
            if !isSendPresented {
                numpadAmount = "0"
            }
        }

    }

}

extension AmountView {
    func numpadRow(_ characters: [String], buttonSize: CGFloat) -> some View {
        HStack(spacing: buttonSize / 2) {
            ForEach(characters, id: \.self) { character in
                NumpadButton(numpadAmount: $numpadAmount, character: character)
                    .frame(width: buttonSize, height: buttonSize)
            }
        }
    }
}

struct NumpadButton: View {
    @Binding var numpadAmount: String
    var character: String

    var body: some View {
        Button {
            if character == "<" {
                if numpadAmount.count > 1 {
                    numpadAmount.removeLast()
                } else {
                    numpadAmount = "0"
                }
            } else if character == " " {
                return
            } else {
                if numpadAmount == "0" {
                    numpadAmount = character
                } else {
                    numpadAmount.append(character)
                }
            }
        } label: {
            Text(character).textStyle(BitcoinTitle3())
        }
    }
}

#Preview{
    AmountView(viewModel: .init(bdkClient: .mock))
}