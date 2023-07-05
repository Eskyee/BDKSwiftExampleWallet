//
//  TransactionDetailsView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 6/22/23.
//

import SwiftUI
import BitcoinDevKit
import WalletUI

struct TransactionDetailsView: View {
    let transaction: TransactionDetails
    let amount: UInt64
    @State private var isCopied = false
    @State private var showCheckmark = false
    
    var body: some View {
        
        VStack {
            
            Spacer()
            
            VStack {
                
                HStack {
                    Text(amount.delimiter)
                    Text("sats")
                }
                .font(.largeTitle)
                .foregroundColor(.primary)
                
                if transaction.confirmationTime == nil {
                    Text("Unconfirmed")
                } else {
                    Text("Confirmed")
                    // Need
                    if let height = transaction.confirmationTime?.height {
                        Text("Block \(height.delimiter)")
                    }
                    if let timestamp = transaction.confirmationTime?.timestamp {
                        Text(timestamp.formattedTime)
                    }
                }
                
                if let fee = transaction.fee {
                    Text("Fee \(fee)")
                }
                
            }
            .foregroundColor(.secondary)
            .padding()
            
            Spacer()
            
            HStack {
                Text("Txid".uppercased())
                    .foregroundColor(.secondary)
                Text(transaction.txid)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Button {
                    UIPasteboard.general.string = transaction.txid
                    isCopied = true
                    showCheckmark = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isCopied = false
                        showCheckmark = false
                    }
                } label: {
                    HStack {
                        withAnimation {
                            Image(systemName: showCheckmark ? "checkmark" : "doc.on.doc")
                        }
                    }
                    .bold()
                    .foregroundColor(.bitcoinOrange)
                }
            }
            .padding()
            
        }
        .padding()
        
    }
}


struct TransactionDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionDetailsView(
            transaction: .init(
                transaction: .none,
                fee: nil,
                received: UInt64(20),
                sent: 21,
                txid: "d652a7cc0138e3277c34f1eab8e63ef445a4b3d02af5f764ed0805b16d33c45b",
                confirmationTime: .init(
                    height: UInt32(796298),
                    timestamp: UInt64(Date().timeIntervalSince1970
                                     )
                )
            ),
            amount: UInt64(2000)
        )
        .previewDisplayName("Light Mode")
        TransactionDetailsView(
            transaction: .init(
                transaction: .none,
                fee: nil,
                received: UInt64(20),
                sent: 21,
                txid: "d652a7cc0138e3277c34f1eab8e63ef445a4b3d02af5f764ed0805b16d33c45b",
                confirmationTime: .init(
                    height: UInt32(796298),
                    timestamp: UInt64(Date().timeIntervalSince1970
                                     )
                )
            ),
            amount: UInt64(200)
        )
        .environment(\.colorScheme, .dark)
        .previewDisplayName("Dark Mode")
    }
}