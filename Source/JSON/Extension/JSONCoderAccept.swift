//
//  JSONCoderAccept.swift
//  SabyJSON
//
//  Created by WOF on 4/15/24.
//

import Foundation

extension JSONEncoder {
    public static func acceptingNonConfirmingFloat() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.nonConformingFloatEncodingStrategy = .convertToString(
            positiveInfinity: "__CO_AB180_SABY_NON_CONFORMING_FLOAT_POSITIVE_INFINITY__",
            negativeInfinity: "__CO_AB180_SABY_NON_CONFORMING_FLOAT_NEGATIVE_INFINITY__",
            nan: "__CO_AB180_SABY_NON_CONFORMING_FLOAT_NAN__"
        )
        return encoder
    }
}

extension JSONDecoder {
    public static func acceptingNonConfirmingFloat() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(
            positiveInfinity: "__CO_AB180_SABY_NON_CONFORMING_FLOAT_POSITIVE_INFINITY__",
            negativeInfinity: "__CO_AB180_SABY_NON_CONFORMING_FLOAT_NEGATIVE_INFINITY__",
            nan: "__CO_AB180_SABY_NON_CONFORMING_FLOAT_NAN__"
        )
        return decoder
    }
}
