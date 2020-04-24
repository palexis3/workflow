import UIKit
import Workflow
import WorkflowUI

internal final class AlertContainerViewController<AlertScreen : Screen>: ScreenViewController<AlertContainerScreen<AlertScreen>> {
    
    private var baseScreenViewController: DescribedViewController? = nil

    private let dimmingView = UIView()
    
    private var alertView : AlertView? = nil
    
    required init(screen: AlertContainerScreen<AlertScreen>, environment: ViewEnvironment) {
        baseScreenViewController = DescribedViewController(screen: screen.baseScreen, environment: environment)
        super.init(screen: screen, environment: environment)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dimmingView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.addSubview(dimmingView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        baseScreenViewController?.view.frame = view.bounds
        dimmingView.frame = view.bounds
        dimmingView.isUserInteractionEnabled = (alertView != nil)
        dimmingView.alpha = (alertView != nil) ? 1 : 0
        
        guard let alertView = alertView else { return }

        var layoutRegion = view.bounds
        if #available(iOS 11.0, *) {
            layoutRegion = layoutRegion.inset(by: view.safeAreaInsets)
        } else {
            let topInset = topLayoutGuide.length
            let bottomInset = bottomLayoutGuide.length
            layoutRegion.origin.y += topInset
            layoutRegion.size.height -= (topInset + bottomInset)
        }
        
        let alertSizeThatFits = alertView.sizeThatFits(CGSize(width: 343.0, height: layoutRegion.size.height))

        alertView.bounds = CGRect(
            x: 0,
            y: 0,
            width: alertSizeThatFits.width,
            height: alertSizeThatFits.height
        )

        alertView.center = CGPoint(
            x: layoutRegion.midX,
            y: layoutRegion.midY
        )
        
    }
    
    override func screenDidChange(from previousScreen: AlertContainerScreen<AlertScreen>, previousEnvironment: ViewEnvironment) {
        update()
    }

    func update() {
        if let baseScreenViewController = baseScreenViewController {
            baseScreenViewController.update(screen: screen.baseScreen,  environment: environment)
        }

        if baseScreenViewController == nil {
            // We don't have a base screen view controller, so make one.
            let viewController = DescribedViewController(screen: screen.baseScreen, environment: environment)
            addChild(viewController)
            view.insertSubview(viewController.view, belowSubview: dimmingView)
            viewController.didMove(toParent: self)
            baseScreenViewController = viewController
        }
        
        if let alert = screen.alert {
            
            if let alertView = alertView {
                alertView.alert = alert
            }
            else {
                let inAlertView = AlertView(alert: alert)
                alertView = inAlertView
                inAlertView.accessibilityViewIsModal = true
                view.insertSubview(inAlertView, aboveSubview: dimmingView)
                view.setNeedsLayout()
                view.layoutIfNeeded()

                self.dimmingView.alpha = 0
                
                UIView.animate(
                    withDuration: 0.1,
                    delay: 0,
                    options: [
                        .curveEaseInOut,
                        .allowUserInteraction
                    ],
                    animations: {
                        self.dimmingView.alpha = 1
                        inAlertView.transform = .identity
                        inAlertView.alpha = 1
                    },
                    completion: { _ in
                        UIAccessibility.post(notification: .screenChanged, argument: nil)
                    }
                )
            }
        }
        else {
            if let alertView = alertView {

                UIView.animate(
                    withDuration: 0.1,
                    delay: 0,
                    options: .curveEaseInOut,
                    animations: {
                        alertView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                        alertView.alpha = 0
                        self.dimmingView.alpha = 0
                    },
                    completion: { _ in
                        alertView.removeFromSuperview()
                        self.view.setNeedsLayout()
                        UIAccessibility.post(notification: .screenChanged, argument: nil)
                    }
                )
                self.alertView = nil
            }
        }
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return baseScreenViewController
    }

    override var childForStatusBarHidden: UIViewController? {
        return baseScreenViewController
    }

    override var childForHomeIndicatorAutoHidden: UIViewController? {
        return baseScreenViewController
    }

    override var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        return baseScreenViewController
    }

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return baseScreenViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }
    
}

private final class AlertView: UIView {
    public var alert : Alert?
    
    public required init(alert: Alert?) {
        self.alert = alert
        super.init(frame: CGRect.zero)
    }
    
    public override convenience init(frame: CGRect) {
        self.init(alert: nil)
        self.frame = frame
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
