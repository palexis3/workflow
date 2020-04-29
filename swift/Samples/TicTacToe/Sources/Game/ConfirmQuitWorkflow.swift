/*
* Copyright 2019 Square Inc.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/
import Workflow
import WorkflowUI
import ReactiveSwift
import BackStackContainer
import AlertContainer


// MARK: Input and Output

struct ConfirmQuitWorkflow: Workflow {
    
   // let baseScreen: AnyScreen
    
   enum Output {
        case cancel
        case quit
    }

}


// MARK: State and Initialization

extension ConfirmQuitWorkflow {

    //typealias State = Void
    
    struct State {
        var step: Step
        
        enum Step {
            case confirmOnce
            case confirmTwice
        }
    }


    func makeInitialState() -> ConfirmQuitWorkflow.State {
        return State(step: .confirmOnce)
    }

    func workflowDidChange(from previousWorkflow: ConfirmQuitWorkflow, state: inout State) {

    }
}


// MARK: Actions

extension ConfirmQuitWorkflow {

    enum Action: WorkflowAction {
        
        case cancel
        case quit
        case confirm

        typealias WorkflowType = ConfirmQuitWorkflow

        func apply(toState state: inout ConfirmQuitWorkflow.State) -> ConfirmQuitWorkflow.Output? {

            switch self {
                case .cancel:
                    return .cancel
                
                case .quit:
                    return .quit
            case .confirm:
                state.step = .confirmTwice
                return nil
            }
        }
    }
}

// MARK: Rendering

extension ConfirmQuitWorkflow {
    
    typealias Rendering = (ConfirmQuitScreen, Alert?)

    func render(state: ConfirmQuitWorkflow.State, context: RenderContext<ConfirmQuitWorkflow>) -> Rendering {
        
        let sink = context.makeSink(of: Action.self)
        var alert: Alert? = nil
        
        switch state.step {
        case .confirmOnce:
            break;
        case .confirmTwice:
            alert = Alert(title: "Confirm Again",
                message: "Do you really want to quit?",
                actions: [AlertAction(title: "Ok",
                                      style: AlertAction.Style.dismiss,
                                      handler: {
                                        sink.send(.quit)
                        }
                    )]
                )
        }
        
        return (ConfirmQuitScreen(
            question: "Are you sure you want to quit?",
            onQuitTapped: {
                sink.send(.confirm)
            },
            onCancelTapped: {
                sink.send(.cancel)
            }), alert)
    }
}
