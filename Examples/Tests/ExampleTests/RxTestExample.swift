import XCTest
import Tablier

import RxSwift
import RxTest

@testable import Example

/// RxTestExample
final class ViewModelTests: XCTestCase {
    func testViewModelMessage() {
        struct Input {
            let rememberMe: Bool
            let validatorResult: Bool
            let apiResult: Bool
        }

        struct Output: Equatable {
            let messageEvents: [Recorded<Event<String>>]
            let validatorEvents: [Recorded<Event<Credential>>]
            let apiClientEvents: [Recorded<Event<Credential>>]
            let credentialStoreEvents: [Recorded<Event<Credential>>]
        }

        let testCredential = Credential(username: "username", password: "password")

        let recipe = Recipe<Input, Output>(sync: { input in
            let disposeBag = DisposeBag()

            let scheduler = TestScheduler(initialClock: 0)

            let validator = MockValidator(scheduler: scheduler, result: input.validatorResult)
            let apiClient = MockAPIClient(scheduler: scheduler, result: input.apiResult)
            let credentialStore = MockCredentialStore(scheduler: scheduler)

            let messageObserver = scheduler.createObserver(String.self)

            let viewModel = ViewModel(validator: validator, apiClient: apiClient, credentialStore: credentialStore)
            viewModel.message.subscribe(messageObserver).disposed(by: disposeBag)

            viewModel.username.accept(testCredential.username)
            viewModel.password.accept(testCredential.password)
            viewModel.rememberMe.accept(input.rememberMe)

            scheduler.createHotObservable(Recorded.events(.next(100, ())))
                .bind(to: viewModel.loginButtonTap)
                .disposed(by: disposeBag)

            scheduler.start()

            return Output(
                messageEvents: messageObserver.events,
                validatorEvents: validator.observer.events,
                apiClientEvents: apiClient.observer.events,
                credentialStoreEvents: credentialStore.observer.events
            )
        })

        recipe.assert(with: self) { when in
            when(.init(rememberMe: false, validatorResult: false, apiResult: false))
                .expect(\.messageEvents, Recorded.events(
                    .next(0, ""),
                    .next(100, "invalid")
                ))
                .expect(\.validatorEvents, Recorded.events(
                    .next(0, testCredential)
                ))
                .expect(\.apiClientEvents, Recorded.events(),
                        description: "API should not get called when the credential is invalid")
                .expect(\.credentialStoreEvents, Recorded.events(),
                        description: "should not store invalid credentials")

            when(.init(rememberMe: false, validatorResult: false, apiResult: true))
                .expect(\.messageEvents, Recorded.events(
                    .next(0, ""),
                    .next(100, "invalid")
                ))
                .expect(\.validatorEvents, Recorded.events(
                    .next(0, testCredential)
                ))
                .expect(\.apiClientEvents, Recorded.events(),
                        description: "API should not get called when the credential is invalid")
                .expect(\.credentialStoreEvents, Recorded.events(),
                        description: "should not store invalid credentials")

            when(.init(rememberMe: false, validatorResult: true, apiResult: false))
                .expect(\.messageEvents, Recorded.events(
                    .next(0, ""),
                    .next(100, "loading"),
                    .next(200, "error")
                ))
                .expect(\.validatorEvents, Recorded.events(
                    .next(0, testCredential)
                ))
                .expect(\.apiClientEvents, Recorded.events(
                    .next(100, testCredential)
                ))
                .expect(\.credentialStoreEvents, Recorded.events(),
                        description: "should not store the credential when remimberMe is false")

            when(.init(rememberMe: false, validatorResult: true, apiResult: true))
                .expect(\.messageEvents, Recorded.events(
                    .next(0, ""),
                    .next(100, "loading"),
                    .next(200, "success")
                ))
                .expect(\.validatorEvents, Recorded.events(
                    .next(0, testCredential)
                ))
                .expect(\.apiClientEvents, Recorded.events(
                    .next(100, testCredential)
                ))
                .expect(\.credentialStoreEvents, Recorded.events(),
                        description: "should not store the credential when remimberMe is false")

            when(.init(rememberMe: true, validatorResult: true, apiResult: false))
                .expect(\.messageEvents, Recorded.events(
                    .next(0, ""),
                    .next(100, "loading"),
                    .next(200, "error")
                ))
                .expect(\.validatorEvents, Recorded.events(
                    .next(0, testCredential)
                ))
                .expect(\.apiClientEvents, Recorded.events(
                    .next(100, testCredential)
                ))
                .expect(\.credentialStoreEvents, Recorded.events(),
                        description: "should not store the credential when API call failed")

            when(.init(rememberMe: true, validatorResult: true, apiResult: true))
                .expect(\.messageEvents, Recorded.events(
                    .next(0, ""),
                    .next(100, "loading"),
                    .next(200, "success")
                ))
                .expect(\.validatorEvents, Recorded.events(
                    .next(0, testCredential)
                ))
                .expect(\.apiClientEvents, Recorded.events(
                    .next(100, testCredential)
                ))
                .expect(\.credentialStoreEvents, Recorded.events(
                    .next(200, testCredential)
                ))
        }
    }
}

struct RandomError: Error {}

struct MockValidator: ValidatorType {
    let observer: TestableObserver<Credential>
    let result: Bool

    init(scheduler: TestScheduler, result: Bool) {
        self.observer = scheduler.createObserver(Credential.self)
        self.result = result
    }

    func validate(credential: Credential) -> Bool {
        observer.onNext(credential)
        return result
    }
}

struct MockAPIClient: APIClientType {
    let observer: TestableObserver<Credential>
    let scheduler: TestScheduler
    let result: Bool

    init(scheduler: TestScheduler, result: Bool) {
        self.observer = scheduler.createObserver(Credential.self)
        self.scheduler = scheduler
        self.result = result
    }

    func login(credential: Credential) -> Single<Void> {
        observer.onNext(credential)
        return Single
            .just(())
            .delay(.seconds(100), scheduler: scheduler)
            .map { [result] in
                if !result { throw RandomError() }
            }
    }
}

struct MockCredentialStore: CredentialStoreType {
    let observer: TestableObserver<Credential>

    init(scheduler: TestScheduler) {
        self.observer = scheduler.createObserver(Credential.self)
    }

    func save(credential: Credential) {
        observer.onNext(credential)
    }
}
