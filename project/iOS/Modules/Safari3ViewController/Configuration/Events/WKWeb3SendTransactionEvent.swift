//
//  Created by Anton Spivak
//

// https://github.com/toncenter/ton-wallet/blob/3ef80a23ce120f3eeabaca06955cb8f767525104/src/js/Controller.js#L1130

import JustonCORE
import UIKit

struct WKWeb3SendTransactionEvent: WKWeb3Event {
    struct Body: Decodable {
        enum DataType: String, Decodable {
            case text
            case hex
            case base64
            case boc
        }

        /// recepient
        let to: String

        /// amount in nanotons
        let value: String

        /// type of `data`
        let dataType: DataType?

        /// depends on `dataType`
        let data: String?

        /// boc
        let stateInit: String?
    }

    static let names = ["ton_sendTransaction"]

    func process(
        account: PersistenceAccount?,
        context: UIViewController,
        url: URL,
        _ body: Body
    ) async throws -> Bool {
        guard let account = account
        else {
            throw WKWeb3Error(.unauthorized)
        }

        guard let _amount = Int64(body.value),
              let address = await DisplayableAddress(string: body.to)
        else {
            throw WKWeb3Error(.internal)
        }

        let amount = Currency(_amount)
        let confirmation = UserConfirmation(
            .transaction(
                host: url.host ?? url.absoluteString,
                destination: address,
                value: amount
            ),
            presentationContext: context
        )

        let authentication = PasscodeAuthentication(
            inside: context
        )

        try await confirmation.confirm()
        let passcode = try await authentication.key()

        var data: Data?
        var initialState: Data?

        if let bodyData = body.data,
           let bodyDataType = body.dataType
        {
            switch bodyDataType {
            case .text:
                data = bodyData.data(using: .utf8, allowLossyConversion: true)
            case .hex:
                data = Data(hex: bodyData)
            case .base64, .boc:
                data = Data(base64Encoded: bodyData)
            }
        }

        if let bodyStateInit = body.stateInit {
            initialState = Data(base64Encoded: bodyStateInit)
        }

        let message = try await account.transfer(
            to: address.concreteAddress,
            amount: amount,
            message: (data, initialState),
            passcode: passcode
        )

        try await message.send()

        let writableAccount = await PersistenceAccount.writeableObject(id: account.objectID)
        try await PersistencePendingTransaction(
            account: writableAccount,
            destinationAddress: address.concreteAddress,
            value: amount,
            estimatedFees: 0,
            body: message.body.data,
            bodyHash: message.bodyHash
        ).save()

        return true
    }
}
