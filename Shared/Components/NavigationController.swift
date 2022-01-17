//
//  NavigationController.swift
//  otus-ios-homework1
//  Created by exey on 09.03.2021.
//
//  Modified by Igor Kim on 25.08.21.
//
import SwiftUI

// MARK: - Models
private struct Screen: Identifiable, Equatable {
    let id: String
    let nextScreen: AnyView

    static func == (lhs: Screen, rhs: Screen) -> Bool {
        lhs.id == rhs.id
    }
}

private struct ScreenStack {
    private var screens: [Screen] = .init()
    
    func top() -> Screen? {
        screens.last
    }
    
    mutating func push(_ s: Screen) {
        screens.append(s)
    }
    
    mutating func popToPrevious() {
        _ = screens.popLast()
    }
    
    mutating func popToRoot() {
        screens.removeAll()
    }
}

// MARK: - ViewModel
public enum PopDestination {
    case previous
    case root
}

public enum NavTransition {
    case none
    case standard
    case custom(AnyTransition)
}

enum NavType {
    case push
    case pop
}

public final class NavControllerViewModel: ObservableObject {
    @Published fileprivate var currentScreen: Screen?
    private var screenStack: ScreenStack = .init() {
        didSet {
            currentScreen = screenStack.top()
        }
    }
    
    // Animations
    var navigationType: NavType = .push
    private let easing: Animation
    
    init(easing: Animation) {
        self.easing = easing
    }
    
    func push<S: View>(_ screenView: S) {
        withAnimation(easing) {
            navigationType = .push
            let screen: Screen = .init(id: UUID().uuidString, nextScreen: AnyView(screenView))
            screenStack.push(screen)
        }
    }
    
    func pop(to: PopDestination = .previous) {
        withAnimation(easing) {
            navigationType = .pop
            switch to {
            case .root:
                screenStack.popToRoot()
            case .previous:
                screenStack.popToPrevious()
            }
        }
    }
}

// MARK: - UI
public struct NavControllerView<Content>: View where Content: View {
    @ObservedObject var viewModel: NavControllerViewModel
    
    private let content: Content
    private let transitions: (push: AnyTransition, pop: AnyTransition)
    
    public init(transition: NavTransition = .standard,
                easing: Animation = .easeOut(duration: 0.33),
                @ViewBuilder content: @escaping () -> Content) {
        
        viewModel = NavControllerViewModel(easing: easing)
        self.content = content()
        
        switch transition {
        case .standard:
            transitions = (
                .asymmetric(insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)),
                .asymmetric(insertion: .move(edge: .leading),
                            removal: .move(edge: .trailing))
            )
        case .custom(let trans):
            transitions = (trans, trans)
        default:
            transitions = (.identity, .identity)
        }
    }

    public var body: some View {
        let isRoot = viewModel.currentScreen == nil
        return ZStack {
            if isRoot {
                content
                    .transition(viewModel.navigationType == .push ? transitions.push : transitions.pop)
                    .environmentObject(viewModel)
            } else {
                viewModel.currentScreen!.nextScreen
                    .transition(viewModel.navigationType == .push ? transitions.push : transitions.pop)
                    .environmentObject(viewModel)
            }
        }
        .onTapGesture { }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onEnded({ value in
                    if !isRoot && value.translation.width > 0 && value.startLocation.x < 20 {
                        viewModel.pop()
                                           
                    }
                })
        )
    }
}

public struct NavPushButton<Label, Destination>: View where Label: View, Destination: View {
    @EnvironmentObject var viewModel: NavControllerViewModel
    
    private let label: () -> Label
    private let destination: Destination
    
    public init(destination: Destination, @ViewBuilder label: @escaping () -> Label) {
        self.destination = destination
        self.label = label
    }

    public var body: some View {
        label().onTapGesture {
            viewModel.push(destination)
        }
    }
}

public struct NavPopButton<Label>: View where Label: View {
    @EnvironmentObject var viewModel: NavControllerViewModel
    
    private let label: () -> Label
    private let destination: PopDestination
    
    public init(destination: PopDestination = .previous, @ViewBuilder label: @escaping () -> Label) {
        self.destination = destination
        self.label = label
    }

    public var body: some View {
        label().onTapGesture {
            viewModel.pop(to: destination)
        }
    }
}
