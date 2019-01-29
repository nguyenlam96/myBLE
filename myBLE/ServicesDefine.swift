//
//  ServicesDefine.swift
//  myBLE
//
//  Created by Nguyen Lam on 1/28/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import Foundation
import CoreBluetooth

enum messengerService: String {
    case serviceUUID = "4F84FA41-4170-4CA4-9F86-57A0F0936879"
    case contentCharacteristicUUID = "83930ED9-F3EF-4863-B105-CEC5927990C3"
    case sendMessageDataCharacteristicUUID = "c411dad0-05dd-0137-602c-3c15c2d77f00"
    case dummyCharacteristicUUID = "77237940-05b9-0137-602b-3c15c2d77f00"
}
