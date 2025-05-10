import SwiftUI

extension EventStatus {
    /// Returns a user-friendly, displayable title for each order status.
    ///
    /// - Note: These values should eventually be localized for international users.
    ///
    /// | Status            | Title                |
    /// |-------------------|----------------------|
    /// | `.submitted`      | "Submitted"          |
    /// | `.routed`         | "Routed"             |
    /// | `.partiallyFilled`| "Partially Completed"|
    /// | `.filled`         | "Completed"          |
    /// | `.cancelled`      | "Cancelled"          |
    /// | `.rejected`       | "Rejected"           |
    ///
    var title: String {
        switch self {
        case .submitted: "Submitted"
        case .routed: "Routed"
        case .partiallyFilled: "Partially Completed"
        case .filled: "Completed"
        case .cancelled: "Cancelled"
        case .rejected: "Rejected"
        }
    }
    /// Returns the associated UI color for each order status, used for consistent visual feedback.
    ///
    /// | Status            | Color    |
    /// |-------------------|----------|
    /// | `.submitted`      | Blue     |
    /// | `.routed`         | Orange   |
    /// | `.partiallyFilled`| Yellow   |
    /// | `.filled`         | Green    |
    /// | `.cancelled`      | Red      |
    /// | `.rejected`       | Gray     |
    ///
    /// These colors help users quickly recognize order states in the UI.
    var color: Color {
        switch self {
        case .submitted: return .blue
        case .routed: return .orange
        case .partiallyFilled: return .yellow
        case .filled: return .green
        case .cancelled: return .red
        case .rejected: return .gray
        }
    }
}
