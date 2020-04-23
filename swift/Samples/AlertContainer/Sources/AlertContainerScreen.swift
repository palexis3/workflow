import WorkflowUI


/// An `AlertContainerScreen` displays a base screen with an optional alert over top of it.
public struct AlertContainerScreen: Screen {

    /// The base screen to show underneath any visible alert.
    public var baseScreen: AnyScreen

    /// The presented alert.
    public var alert: Alert?

    public init<ScreenType: Screen>(baseScreen: ScreenType, alert: Alert? = nil) {
        self.baseScreen = AnyScreen(baseScreen)
        self.alert = alert
    }

    public func viewControllerDescription(environment: ViewEnvironment) -> ViewControllerDescription {
        return AlertContainerViewController.description(for: self, environment: environment)
    }
}

public struct Alert {

    public var title: String
    public var message: String
    public var actions: [Action]

    public init(title: String, message: String, actions: [Action]) {
        self.title = title
        self.message = message
        self.actions = actions
    }
}

public struct Action {

    public var title: String
    public var style: Style
    public var handler: () -> Void

    public init(title: String, style: Style, handler: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

extension Action {

    public enum Style {
        case standard

        case primary
        case destructive
    }

}
