
import SwiftUI

struct Theme {
    let primary: Color
    let secondary: Color
}

extension Theme {
    static let `default` = Theme(
        primary: Color.blue,
        secondary: Color.gray
    )
}
