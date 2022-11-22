//
//  ActiveWorkoutView.swift
//  
//
//  Created by Максим Казаков on 03.09.2022.
//

import Foundation
import SwiftUI
import Combine
import ComposableArchitecture

import ActiveWorkoutCore
import WorkoutPlanCore
import IntervalCore
import LocationAccessUI
import LocationAccessCore

public struct ActiveWorkoutView: View {
    public init(store: Store<ActiveWorkout, ActiveWorkoutAction>) {
        self.store = store
    }

    let store: Store<ActiveWorkout, ActiveWorkoutAction>

    public var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                GeometryReader { proxy in }
                    .background(Color.yellow.ignoresSafeArea())

                ZStack {
                    if viewStore.state.preparationStatus.isPrepared {
                        VStack {
                            switch viewStore.state.currentIntervalStep.finishType {
                            case let .byDistance(meters):
                                DistanceTimerView(
                                    viewStore: viewStore,
                                    fullDistanceMeters: meters,
                                    nameView: Text(viewStore.currentIntervalStep.name).font(.title2)
                                )
                                    .id(viewStore.state.currentIntervalStep.id)

                            case let .byDuration(seconds):
                                CountdownTimerView(
                                    viewModel: CountdownTimerViewModel(
                                        fullTime: seconds * 1000,
                                        viewStore: viewStore
                                    )
                                )
                                .id(viewStore.state.currentIntervalStep.id)

                            case .byTappingButton:
                                TimerView(
                                    viewStore: viewStore,
                                    nameView: Text(viewStore.currentIntervalStep.name).font(.title2)
                                )
                                .id(viewStore.state.currentIntervalStep.id)
                            }

                            HStack {
                                Spacer()
                                NextStepButton(title: "next", action: { viewStore.send(.stepFinished) })
                            }
                            .opacity(viewStore.state.status == .initial ? 0 : 1)
                        }
                        .foregroundColor(.black)

                        VStack {
                            switch viewStore.state.status {
                            case .paused, .inProgress:
                                HStack {
                                    StopButton(onStop: { viewStore.send(.stop) })
                                    Spacer()
                                    if let pauseButtonState = mapStatusToButton(viewStore.state.status) {
                                        PauseResumeButton(state: pauseButtonState,
                                                          onStart: { viewStore.send(.start) },
                                                          onPause: { viewStore.send(.pause) })
                                    }
                                }
                                Spacer()
                            case .initial:
                                Spacer()
                                HStack {
                                    Spacer()
                                    StartButton(onStart: { viewStore.send(.start) })
                                    Spacer()
                                }
                            case .stopped:
                                HStack {
                                    Spacer()
                                    Button(
                                        action: { viewStore.send(.close) },
                                        label: {
                                            Image(systemName: "xmark")
                                                .foregroundColor(.white)
                                                .padding(8)
                                                .background(Color.black)
                                                .clipShape(Circle())
                                        }
                                    )
                                }
                                Spacer()
                            }
                        }
                    } else {
                        LocationAccessView(
                            store: store.scope(
                                state: \.preparationStatus.locationStatus,
                                action: ActiveWorkoutAction.locationAccess
                            )
                        )
                    }
                }
                .padding(.horizontal, 12)
            }
            .onAppear(perform: { viewStore.send(.onAppear) })
        }
    }


    var progressView: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .black))
    }

    func mapStatusToButton(_ status: ActiveWorkoutStatus) -> PauseResumeButtonState? {
        switch status {
        case .initial, .stopped: return nil
        case .inProgress: return .playing
        case .paused: return .paused
        }
    }
}

struct ActiveWorkoutView_Previews: PreviewProvider {
    static let workoutPlan = WorkoutPlan(
        id: UUID(),
        name: "Running",
        intervals: [
            Interval(
                id: Interval.Id(),
                name: "Running",
                finishType: .byDuration(seconds: 60),
                recoveryInfo: RecoveryInfo(finishType: .byTappingButton, isEnabled: false),
                repeatCount: 2,
                pulseRange: nil,
                paceRange: nil
            )
        ]
    )

    static var previews: some View {
        ActiveWorkoutView(store: Store<ActiveWorkout, ActiveWorkoutAction>(
            initialState: ActiveWorkout(
                id: UUID(),
                workoutPlan: workoutPlan,
                intervalSteps: []
            ),
            reducer: activeWorkoutProgressReducer,
            environment: ActiveWorkoutEnvironment(
                uuid: UUID.init,
                mainQueue: .immediate.eraseToAnyScheduler(),
                now: Date.init,
                locationManager: .failing
            )
        ))
    }
}
