//
//  MockCall.swift
//  SabyTestMock
//
//  Created by WOF on 2023/07/05.
//

import Foundation

public func mockCall<
    Argument0: Mockable,
    Result
>(
    _ function: (
        Argument0
    ) -> Result
) -> Result {
    function(
        Argument0.mock()
    )
}

public func mockCall<
    Argument0: Mockable,
    Argument1: Mockable,
    Result
>(
    _ function: (
        Argument0,
        Argument1
    ) -> Result
) -> Result {
    function(
        Argument0.mock(),
        Argument1.mock()
    )
}

public func mockCall<
    Argument0: Mockable,
    Argument1: Mockable,
    Argument2: Mockable,
    Result
>(
    _ function: (
        Argument0,
        Argument1,
        Argument2
    ) -> Result
) -> Result {
    function(
        Argument0.mock(),
        Argument1.mock(),
        Argument2.mock()
    )
}

public func mockCall<
    Argument0: Mockable,
    Argument1: Mockable,
    Argument2: Mockable,
    Argument3: Mockable,
    Result
>(
    _ function: (
        Argument0,
        Argument1,
        Argument2,
        Argument3
    ) -> Result
) -> Result {
    function(
        Argument0.mock(),
        Argument1.mock(),
        Argument2.mock(),
        Argument3.mock()
    )
}

public func mockCall<
    Argument0: Mockable,
    Argument1: Mockable,
    Argument2: Mockable,
    Argument3: Mockable,
    Argument4: Mockable,
    Result
>(
    _ function: (
        Argument0,
        Argument1,
        Argument2,
        Argument3,
        Argument4
    ) -> Result
) -> Result {
    function(
        Argument0.mock(),
        Argument1.mock(),
        Argument2.mock(),
        Argument3.mock(),
        Argument4.mock()
    )
}

public func mockCall<
    Argument0: Mockable,
    Argument1: Mockable,
    Argument2: Mockable,
    Argument3: Mockable,
    Argument4: Mockable,
    Argument5: Mockable,
    Result
>(
    _ function: (
        Argument0,
        Argument1,
        Argument2,
        Argument3,
        Argument4,
        Argument5
    ) -> Result
) -> Result {
    function(
        Argument0.mock(),
        Argument1.mock(),
        Argument2.mock(),
        Argument3.mock(),
        Argument4.mock(),
        Argument5.mock()
    )
}

public func mockCall<
    Argument0: Mockable,
    Argument1: Mockable,
    Argument2: Mockable,
    Argument3: Mockable,
    Argument4: Mockable,
    Argument5: Mockable,
    Argument6: Mockable,
    Result
>(
    _ function: (
        Argument0,
        Argument1,
        Argument2,
        Argument3,
        Argument4,
        Argument5,
        Argument6
    ) -> Result
) -> Result {
    function(
        Argument0.mock(),
        Argument1.mock(),
        Argument2.mock(),
        Argument3.mock(),
        Argument4.mock(),
        Argument5.mock(),
        Argument6.mock()
    )
}

public func mockCall<
    Argument0: Mockable,
    Argument1: Mockable,
    Argument2: Mockable,
    Argument3: Mockable,
    Argument4: Mockable,
    Argument5: Mockable,
    Argument6: Mockable,
    Argument7: Mockable,
    Result
>(
    _ function: (
        Argument0,
        Argument1,
        Argument2,
        Argument3,
        Argument4,
        Argument5,
        Argument6,
        Argument7
    ) -> Result
) -> Result {
    function(
        Argument0.mock(),
        Argument1.mock(),
        Argument2.mock(),
        Argument3.mock(),
        Argument4.mock(),
        Argument5.mock(),
        Argument6.mock(),
        Argument7.mock()
    )
}

public func mockCall<
    Argument0: Mockable,
    Argument1: Mockable,
    Argument2: Mockable,
    Argument3: Mockable,
    Argument4: Mockable,
    Argument5: Mockable,
    Argument6: Mockable,
    Argument7: Mockable,
    Argument8: Mockable,
    Result
>(
    _ function: (
        Argument0,
        Argument1,
        Argument2,
        Argument3,
        Argument4,
        Argument5,
        Argument6,
        Argument7,
        Argument8
    ) -> Result
) -> Result {
    function(
        Argument0.mock(),
        Argument1.mock(),
        Argument2.mock(),
        Argument3.mock(),
        Argument4.mock(),
        Argument5.mock(),
        Argument6.mock(),
        Argument7.mock(),
        Argument8.mock()
    )
}

public func mockCall<
    Argument0: Mockable,
    Argument1: Mockable,
    Argument2: Mockable,
    Argument3: Mockable,
    Argument4: Mockable,
    Argument5: Mockable,
    Argument6: Mockable,
    Argument7: Mockable,
    Argument8: Mockable,
    Argument9: Mockable,
    Result
>(
    _ function: (
        Argument0,
        Argument1,
        Argument2,
        Argument3,
        Argument4,
        Argument5,
        Argument6,
        Argument7,
        Argument8,
        Argument9
    ) -> Result
) -> Result {
    function(
        Argument0.mock(),
        Argument1.mock(),
        Argument2.mock(),
        Argument3.mock(),
        Argument4.mock(),
        Argument5.mock(),
        Argument6.mock(),
        Argument7.mock(),
        Argument8.mock(),
        Argument9.mock()
    )
}

public func mockCall<
    Argument0: Mockable,
    Argument1: Mockable,
    Argument2: Mockable,
    Argument3: Mockable,
    Argument4: Mockable,
    Argument5: Mockable,
    Argument6: Mockable,
    Argument7: Mockable,
    Argument8: Mockable,
    Argument9: Mockable,
    Argument10: Mockable,
    Result
>(
    _ function: (
        Argument0,
        Argument1,
        Argument2,
        Argument3,
        Argument4,
        Argument5,
        Argument6,
        Argument7,
        Argument8,
        Argument9,
        Argument10
    ) -> Result
) -> Result {
    function(
        Argument0.mock(),
        Argument1.mock(),
        Argument2.mock(),
        Argument3.mock(),
        Argument4.mock(),
        Argument5.mock(),
        Argument6.mock(),
        Argument7.mock(),
        Argument8.mock(),
        Argument9.mock(),
        Argument10.mock()
    )
}

public func mockCall<
    Argument0: Mockable,
    Argument1: Mockable,
    Argument2: Mockable,
    Argument3: Mockable,
    Argument4: Mockable,
    Argument5: Mockable,
    Argument6: Mockable,
    Argument7: Mockable,
    Argument8: Mockable,
    Argument9: Mockable,
    Argument10: Mockable,
    Argument11: Mockable,
    Result
>(
    _ function: (
        Argument0,
        Argument1,
        Argument2,
        Argument3,
        Argument4,
        Argument5,
        Argument6,
        Argument7,
        Argument8,
        Argument9,
        Argument10,
        Argument11
    ) -> Result
) -> Result {
    function(
        Argument0.mock(),
        Argument1.mock(),
        Argument2.mock(),
        Argument3.mock(),
        Argument4.mock(),
        Argument5.mock(),
        Argument6.mock(),
        Argument7.mock(),
        Argument8.mock(),
        Argument9.mock(),
        Argument10.mock(),
        Argument11.mock()
    )
}

public func mockCall<
    Argument0: Mockable,
    Argument1: Mockable,
    Argument2: Mockable,
    Argument3: Mockable,
    Argument4: Mockable,
    Argument5: Mockable,
    Argument6: Mockable,
    Argument7: Mockable,
    Argument8: Mockable,
    Argument9: Mockable,
    Argument10: Mockable,
    Argument11: Mockable,
    Argument12: Mockable,
    Result
>(
    _ function: (
        Argument0,
        Argument1,
        Argument2,
        Argument3,
        Argument4,
        Argument5,
        Argument6,
        Argument7,
        Argument8,
        Argument9,
        Argument10,
        Argument11,
        Argument12
    ) -> Result
) -> Result {
    function(
        Argument0.mock(),
        Argument1.mock(),
        Argument2.mock(),
        Argument3.mock(),
        Argument4.mock(),
        Argument5.mock(),
        Argument6.mock(),
        Argument7.mock(),
        Argument8.mock(),
        Argument9.mock(),
        Argument10.mock(),
        Argument11.mock(),
        Argument12.mock()
    )
}

public func mockCall<
    Argument0: Mockable,
    Argument1: Mockable,
    Argument2: Mockable,
    Argument3: Mockable,
    Argument4: Mockable,
    Argument5: Mockable,
    Argument6: Mockable,
    Argument7: Mockable,
    Argument8: Mockable,
    Argument9: Mockable,
    Argument10: Mockable,
    Argument11: Mockable,
    Argument12: Mockable,
    Argument13: Mockable,
    Result
>(
    _ function: (
        Argument0,
        Argument1,
        Argument2,
        Argument3,
        Argument4,
        Argument5,
        Argument6,
        Argument7,
        Argument8,
        Argument9,
        Argument10,
        Argument11,
        Argument12,
        Argument13
    ) -> Result
) -> Result {
    function(
        Argument0.mock(),
        Argument1.mock(),
        Argument2.mock(),
        Argument3.mock(),
        Argument4.mock(),
        Argument5.mock(),
        Argument6.mock(),
        Argument7.mock(),
        Argument8.mock(),
        Argument9.mock(),
        Argument10.mock(),
        Argument11.mock(),
        Argument12.mock(),
        Argument13.mock()
    )
}

public func mockCall<
    Argument0: Mockable,
    Argument1: Mockable,
    Argument2: Mockable,
    Argument3: Mockable,
    Argument4: Mockable,
    Argument5: Mockable,
    Argument6: Mockable,
    Argument7: Mockable,
    Argument8: Mockable,
    Argument9: Mockable,
    Argument10: Mockable,
    Argument11: Mockable,
    Argument12: Mockable,
    Argument13: Mockable,
    Argument14: Mockable,
    Result
>(
    _ function: (
        Argument0,
        Argument1,
        Argument2,
        Argument3,
        Argument4,
        Argument5,
        Argument6,
        Argument7,
        Argument8,
        Argument9,
        Argument10,
        Argument11,
        Argument12,
        Argument13,
        Argument14
    ) -> Result
) -> Result {
    function(
        Argument0.mock(),
        Argument1.mock(),
        Argument2.mock(),
        Argument3.mock(),
        Argument4.mock(),
        Argument5.mock(),
        Argument6.mock(),
        Argument7.mock(),
        Argument8.mock(),
        Argument9.mock(),
        Argument10.mock(),
        Argument11.mock(),
        Argument12.mock(),
        Argument13.mock(),
        Argument14.mock()
    )
}

public func mockCall<
    Argument0: Mockable,
    Argument1: Mockable,
    Argument2: Mockable,
    Argument3: Mockable,
    Argument4: Mockable,
    Argument5: Mockable,
    Argument6: Mockable,
    Argument7: Mockable,
    Argument8: Mockable,
    Argument9: Mockable,
    Argument10: Mockable,
    Argument11: Mockable,
    Argument12: Mockable,
    Argument13: Mockable,
    Argument14: Mockable,
    Argument15: Mockable,
    Result
>(
    _ function: (
        Argument0,
        Argument1,
        Argument2,
        Argument3,
        Argument4,
        Argument5,
        Argument6,
        Argument7,
        Argument8,
        Argument9,
        Argument10,
        Argument11,
        Argument12,
        Argument13,
        Argument14,
        Argument15
    ) -> Result
) -> Result {
    function(
        Argument0.mock(),
        Argument1.mock(),
        Argument2.mock(),
        Argument3.mock(),
        Argument4.mock(),
        Argument5.mock(),
        Argument6.mock(),
        Argument7.mock(),
        Argument8.mock(),
        Argument9.mock(),
        Argument10.mock(),
        Argument11.mock(),
        Argument12.mock(),
        Argument13.mock(),
        Argument14.mock(),
        Argument15.mock()
    )
}

public func mockCall<
    Argument0: Mockable,
    Argument1: Mockable,
    Argument2: Mockable,
    Argument3: Mockable,
    Argument4: Mockable,
    Argument5: Mockable,
    Argument6: Mockable,
    Argument7: Mockable,
    Argument8: Mockable,
    Argument9: Mockable,
    Argument10: Mockable,
    Argument11: Mockable,
    Argument12: Mockable,
    Argument13: Mockable,
    Argument14: Mockable,
    Argument15: Mockable,
    Argument16: Mockable,
    Result
>(
    _ function: (
        Argument0,
        Argument1,
        Argument2,
        Argument3,
        Argument4,
        Argument5,
        Argument6,
        Argument7,
        Argument8,
        Argument9,
        Argument10,
        Argument11,
        Argument12,
        Argument13,
        Argument14,
        Argument15,
        Argument16
    ) -> Result
) -> Result {
    function(
        Argument0.mock(),
        Argument1.mock(),
        Argument2.mock(),
        Argument3.mock(),
        Argument4.mock(),
        Argument5.mock(),
        Argument6.mock(),
        Argument7.mock(),
        Argument8.mock(),
        Argument9.mock(),
        Argument10.mock(),
        Argument11.mock(),
        Argument12.mock(),
        Argument13.mock(),
        Argument14.mock(),
        Argument15.mock(),
        Argument16.mock()
    )
}

public func mockCall<
    Argument0: Mockable,
    Argument1: Mockable,
    Argument2: Mockable,
    Argument3: Mockable,
    Argument4: Mockable,
    Argument5: Mockable,
    Argument6: Mockable,
    Argument7: Mockable,
    Argument8: Mockable,
    Argument9: Mockable,
    Argument10: Mockable,
    Argument11: Mockable,
    Argument12: Mockable,
    Argument13: Mockable,
    Argument14: Mockable,
    Argument15: Mockable,
    Argument16: Mockable,
    Argument17: Mockable,
    Result
>(
    _ function: (
        Argument0,
        Argument1,
        Argument2,
        Argument3,
        Argument4,
        Argument5,
        Argument6,
        Argument7,
        Argument8,
        Argument9,
        Argument10,
        Argument11,
        Argument12,
        Argument13,
        Argument14,
        Argument15,
        Argument16,
        Argument17
    ) -> Result
) -> Result {
    function(
        Argument0.mock(),
        Argument1.mock(),
        Argument2.mock(),
        Argument3.mock(),
        Argument4.mock(),
        Argument5.mock(),
        Argument6.mock(),
        Argument7.mock(),
        Argument8.mock(),
        Argument9.mock(),
        Argument10.mock(),
        Argument11.mock(),
        Argument12.mock(),
        Argument13.mock(),
        Argument14.mock(),
        Argument15.mock(),
        Argument16.mock(),
        Argument17.mock()
    )
}

public func mockCall<
    Argument0: Mockable,
    Argument1: Mockable,
    Argument2: Mockable,
    Argument3: Mockable,
    Argument4: Mockable,
    Argument5: Mockable,
    Argument6: Mockable,
    Argument7: Mockable,
    Argument8: Mockable,
    Argument9: Mockable,
    Argument10: Mockable,
    Argument11: Mockable,
    Argument12: Mockable,
    Argument13: Mockable,
    Argument14: Mockable,
    Argument15: Mockable,
    Argument16: Mockable,
    Argument17: Mockable,
    Argument18: Mockable,
    Result
>(
    _ function: (
        Argument0,
        Argument1,
        Argument2,
        Argument3,
        Argument4,
        Argument5,
        Argument6,
        Argument7,
        Argument8,
        Argument9,
        Argument10,
        Argument11,
        Argument12,
        Argument13,
        Argument14,
        Argument15,
        Argument16,
        Argument17,
        Argument18
    ) -> Result
) -> Result {
    function(
        Argument0.mock(),
        Argument1.mock(),
        Argument2.mock(),
        Argument3.mock(),
        Argument4.mock(),
        Argument5.mock(),
        Argument6.mock(),
        Argument7.mock(),
        Argument8.mock(),
        Argument9.mock(),
        Argument10.mock(),
        Argument11.mock(),
        Argument12.mock(),
        Argument13.mock(),
        Argument14.mock(),
        Argument15.mock(),
        Argument16.mock(),
        Argument17.mock(),
        Argument18.mock()
    )
}

public func mockCall<
    Argument0: Mockable,
    Argument1: Mockable,
    Argument2: Mockable,
    Argument3: Mockable,
    Argument4: Mockable,
    Argument5: Mockable,
    Argument6: Mockable,
    Argument7: Mockable,
    Argument8: Mockable,
    Argument9: Mockable,
    Argument10: Mockable,
    Argument11: Mockable,
    Argument12: Mockable,
    Argument13: Mockable,
    Argument14: Mockable,
    Argument15: Mockable,
    Argument16: Mockable,
    Argument17: Mockable,
    Argument18: Mockable,
    Argument19: Mockable,
    Result
>(
    _ function: (
        Argument0,
        Argument1,
        Argument2,
        Argument3,
        Argument4,
        Argument5,
        Argument6,
        Argument7,
        Argument8,
        Argument9,
        Argument10,
        Argument11,
        Argument12,
        Argument13,
        Argument14,
        Argument15,
        Argument16,
        Argument17,
        Argument18,
        Argument19
    ) -> Result
) -> Result {
    function(
        Argument0.mock(),
        Argument1.mock(),
        Argument2.mock(),
        Argument3.mock(),
        Argument4.mock(),
        Argument5.mock(),
        Argument6.mock(),
        Argument7.mock(),
        Argument8.mock(),
        Argument9.mock(),
        Argument10.mock(),
        Argument11.mock(),
        Argument12.mock(),
        Argument13.mock(),
        Argument14.mock(),
        Argument15.mock(),
        Argument16.mock(),
        Argument17.mock(),
        Argument18.mock(),
        Argument19.mock()
    )
}
