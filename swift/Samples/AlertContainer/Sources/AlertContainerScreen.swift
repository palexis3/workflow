import WorkflowUI


/// An `AlertContainerScreen` displays a base screen with an optional alert over top of it.
public struct AlertContainerScreen<BaseScreen: Screen>: Screen {

    /// The base screen to show underneath any visible alert.
    public var baseScreen: BaseScreen

    /// The presented alert.
    public var alert: Alert?

    public init(baseScreen: BaseScreen, alert: Alert? = nil) {
        self.baseScreen = baseScreen
        self.alert = alert
    }

    public func viewControllerDescription(environment: ViewEnvironment) -> ViewControllerDescription {
        return AlertContainerViewController.description(for: self, environment: environment)
    }
}

public struct Alert {

    public var title: String
    public var message: String
    public var actions: [AlertAction]

    public init(title: String, message: String, actions: [AlertAction]) {
        self.title = title
        self.message = message
        self.actions = actions
    }
}

public struct AlertAction {

    public var title: String
    public var style: Style
    public var handler: () -> Void

    public init(title: String, style: Style, handler: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

extension AlertAction {

    public enum Style {
        case primary
        case secondary
        case dismiss
    }

}
