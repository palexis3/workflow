import UIKit
import Workflow
import WorkflowUI

internal final class AlertContainerViewController<AlertScreen : Screen>: ScreenViewController<AlertContainerScreen<AlertScreen>> {
    
    private var baseScreenViewController: DescribedViewController

    private let dimmingView = UIView()
    
    private var alertView : AlertView? = nil
    
    required init(screen: AlertContainerScreen<AlertScreen>, environment: ViewEnvironment) {
        baseScreenViewController = DescribedViewController(screen: screen.baseScreen, environment: environment)
        super.init(screen: screen, environment: environment)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(baseScreenViewController)
        view.addSubview(baseScreenViewController.view)
        baseScreenViewController.didMove(toParent: self)

        dimmingView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.addSubview(dimmingView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        baseScreenViewController.view.frame = view.bounds
        
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
        baseScreenViewController.update(screen: screen.baseScreen,  environment: environment)
        
        if let alert = screen.alert {
            
            if let alertView = alertView {
                alertView.alert = alert
            }
            else {
                let inAlertView = AlertView(alert: alert)
                inAlertView.backgroundColor = .init(white: 0.95, alpha: 1)
                inAlertView.layer.cornerRadius = 10
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
        return baseScreenViewController.supportedInterfaceOrientations
    }
    
}

private final class AlertView: UIView {
    public var alert : Alert?
    private lazy var title: UILabel = {
      let title = UILabel()
      title.font = UIFont.systemFont(ofSize: 18, weight: .medium)
      title.textAlignment = .center
      title.translatesAutoresizingMaskIntoConstraints = false
      return title
    }()
    
    private lazy var message: UILabel = {
      let message = UILabel()
        message.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        message.textAlignment = .center
        message.numberOfLines = 0
        message.lineBreakMode = .byWordWrapping
        message.translatesAutoresizingMaskIntoConstraints = false
        return message
    }()
    
    public required init(alert: Alert?) {
        self.alert = alert
        super.init(frame: CGRect(x:0,y:0,width:343,height:150))
        commonInit()
    }
    
    public override convenience init(frame: CGRect) {
        self.init(alert: nil)
        self.frame = frame
        commonInit()
    }
    
    private func commonInit () {
        
        if let alert = alert {
            
            title.text = alert.title
            addSubview(title)
            
            message.text = alert.message
            addSubview(message)
            
            let buttonStackView = setupButtons(actions: alert.actions)
            addSubview(buttonStackView)
            
            var constraints: Array<NSLayoutConstraint> = []

            constraints.append(title.topAnchor.constraint(equalTo: topAnchor, constant: 10))
            constraints.append(title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10))
            constraints.append(title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10))
            constraints.append(title.heightAnchor.constraint(equalToConstant: 25))

            constraints.append(message.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10))
            constraints.append(message.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10))
            constraints.append(message.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10))
            constraints.append(message.heightAnchor.constraint(equalToConstant: 25))
            
            constraints.append(buttonStackView.topAnchor.constraint(greaterThanOrEqualTo: message.bottomAnchor, constant: 15))
            constraints.append(buttonStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0))
            constraints.append(buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0))
            constraints.append(buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0))
            constraints.append(buttonStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50))
            
            addConstraints(constraints)
            
        }
    }
    
    private func setupButtons(actions: [AlertAction]) -> UIStackView {
        
        let buttonStackView = UIStackView()
        buttonStackView.axis = actions.count == 2 ? .horizontal : .vertical
        buttonStackView.distribution = .fillEqually
        buttonStackView.alignment = .fill
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        for action in actions {
            let alertButton = AlertButton(action: action)
            alertButton.backgroundColor = backgroundColor
            alertButton.layer.borderColor = UIColor.gray.cgColor
            alertButton.layer.borderWidth = 0.2
            alertButton.translatesAutoresizingMaskIntoConstraints = false
            
            buttonStackView.addArrangedSubview(alertButton)
        }
        
        return buttonStackView
    }
    
    private func setupLayout() {
        
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private final class AlertButton: UIButton {
    private var action: AlertAction
    private var actionHandler: (() -> Void)?
    
    required init(action: AlertAction) {
        self.action = action
        
        super.init(frame: .zero)
        commonInit()
    }
    
    private func commonInit() {
        setTitle(action.title, for: .normal)
        setTitleColor(.black, for: .normal)
        actionHandler = action.handler
        self.addTarget(self, action: #selector(triggerActionHandler), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func triggerActionHandler() {
        if let actionHandler = actionHandler {
            actionHandler()
        }
    }
}

