//
//  WalletView.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 5/23/23.
//

import BitcoinDevKit
import BitcoinUI
import SwiftUI

struct WalletView: View {
    @Bindable var viewModel: WalletViewModel
    @State private var isAnimating: Bool = false
    @State private var isFirstAppear = true
    @State private var newTransactionSent = false

    var body: some View {

        NavigationView {

            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 20) {

                    VStack(spacing: 10) {
                        Text("Bitcoin".uppercased())
                            .fontWeight(.semibold)
                            .fontWidth(.expanded)
                            .foregroundColor(.bitcoinOrange)
                            .scaleEffect(isAnimating ? 1.0 : 0.6)
                            .onAppear {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    isAnimating = true
                                }
                            }
                        withAnimation {
                            HStack(spacing: 15) {
                                Image(systemName: "bitcoinsign")
                                    .foregroundColor(.secondary)
                                    .font(.title)
                                    .fontWeight(.thin)
                                Text(viewModel.balanceTotal.formattedSatoshis())
                                    .contentTransition(.numericText())
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                Text("sats")
                                    .foregroundColor(.secondary)
                                    .fontWeight(.thin)
                            }
                            .font(.largeTitle)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        }
                        HStack {
                            if viewModel.walletSyncState == .syncing {
                                Image(systemName: "chart.bar.fill")
                                    .symbolEffect(
                                        .variableColor.cumulative
                                    )
                            }
                            Text(viewModel.satsPrice, format: .currency(code: "USD"))
                                .contentTransition(.numericText())
                                .fontDesign(.rounded)
                        }
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                    }
                    .padding(.top, 40.0)
                    .padding(.bottom, 20.0)

                    VStack {
                        HStack {
                            Text("Activity")
                            if viewModel.walletSyncState == .synced {
                                Text(
                                    "\(viewModel.transactions.count) \(viewModel.transactions.count == 1 ? "Transaction" : "Transactions")"
                                )
                                .fontWeight(.thin)
                                .font(.caption2)
                            }
                            Spacer()
                            if viewModel.walletSyncState == .syncing {
                                HStack {
                                    if viewModel.progress < 1.0 {
                                        Text("\(viewModel.inspectedScripts)")
                                            .padding(.trailing, -5.0)
                                            .fontWeight(.semibold)
                                            .contentTransition(.numericText())
                                            .transition(.opacity)

                                        if !viewModel.bdkClient.needsFullScan() {
                                            Text("/")
                                                .padding(.trailing, -5.0)
                                                .transition(.opacity)
                                            Text("\(viewModel.totalScripts)")
                                                .contentTransition(.numericText())
                                                .transition(.opacity)
                                        }
                                    }

                                    if !viewModel.bdkClient.needsFullScan() {
                                        Text(
                                            String(
                                                format: "%.0f%%",
                                                viewModel.progress * 100
                                            )
                                        )
                                        .contentTransition(.numericText())
                                        .transition(.opacity)
                                    }
                                }
                                .fontDesign(.monospaced)
                                .foregroundColor(.secondary)
                                .font(.caption2)
                                .fontWeight(.thin)
                                .animation(.easeInOut, value: viewModel.inspectedScripts)
                                .animation(.easeInOut, value: viewModel.totalScripts)
                                .animation(.easeInOut, value: viewModel.progress)
                            }
                            HStack {
                                HStack(spacing: 5) {
                                    if viewModel.walletSyncState == .syncing {
                                        Image(systemName: "slowmo")
                                            .symbolEffect(
                                                .variableColor.cumulative
                                            )
                                            .contentTransition(.symbolEffect(.replace.offUp))
                                    } else if viewModel.walletSyncState == .synced {
                                        Image(systemName: "checkmark.circle")
                                            .foregroundColor(
                                                viewModel.walletSyncState == .synced
                                                    ? .green : .secondary
                                            )
                                    } else if viewModel.walletSyncState == .notStarted {
                                        Image(systemName: "goforward")
                                    } else {
                                        Image(
                                            systemName: "person.crop.circle.badge.exclamationmark"
                                        )
                                    }

                                }
                            }
                            .foregroundColor(.secondary)
                            .font(.caption)
                        }
                        .fontWeight(.bold)
                        WalletTransactionListView(
                            transactions: viewModel.transactions,
                            walletSyncState: viewModel.walletSyncState,
                            viewModel: .init()
                        )
                        .refreshable {
                            await viewModel.syncOrFullScan()
                            viewModel.getBalance()
                            viewModel.getTransactions()
                            await viewModel.getPrices()
                        }
                        Spacer()
                    }

                }
                .padding()
                .onReceive(
                    NotificationCenter.default.publisher(for: Notification.Name("TransactionSent")),
                    perform: { _ in
                        newTransactionSent = true
                    }
                )
                .task {
                    if isFirstAppear || newTransactionSent {
                        await viewModel.syncOrFullScan()
                        isFirstAppear = false
                        newTransactionSent = false
                    }
                    viewModel.getBalance()
                    viewModel.getTransactions()
                    await viewModel.getPrices()
                }

            }

        }
        .alert(isPresented: $viewModel.showingWalletViewErrorAlert) {
            Alert(
                title: Text("Wallet Error"),
                message: Text(viewModel.walletViewError?.description ?? "Unknown"),
                dismissButton: .default(Text("OK")) {
                    viewModel.walletViewError = nil
                }
            )
        }

    }

}

#if DEBUG
    #Preview("WalletView - en") {
        WalletView(
            viewModel: .init(
                priceClient: .mock,
                bdkClient: .mock,
                walletSyncState: .synced,
                transactions: [.mock]
            )
        )
    }
    #Preview("WalletView - fr") {
        WalletView(
            viewModel: .init(
                priceClient: .mock,
                bdkClient: .mock,
                walletSyncState: .synced,
                transactions: [.mock]
            )
        )
        .environment(\.locale, .init(identifier: "fr"))
    }
#endif
