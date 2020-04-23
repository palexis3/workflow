import UIKit
import Workflow
import WorkflowUI

internal final class AlertContainerViewController: ScreenViewController<AlertContainerScreen> {
    
    private var baseScreenViewController: DescribedViewController? = nil

    private let dimmingView = UIView()
    
    required init(screen: AlertContainerScreen, environment: ViewEnvironment) {
        baseScreenViewController = DescribedViewController(screen: screen.baseScreen, environment: environment)
        super.init(screen: screen, environment: environment)
    }
    
    override func screenDidChange(from previousScreen: AlertContainerScreen, previousEnvironment: ViewEnvironment) {
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    func update() {
        
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
