import RxSwift
import RxRelay

public struct Credential: Equatable {
    let username: String
    let password: String
}

public protocol ValidatorType {
    func validate(credential: Credential) -> Bool
}

public protocol APIClientType {
    func login(credential: Credential) -> Single<Void>
}

public protocol CredentialStoreType {
    func save(credential: Credential)
}

public struct ViewModel {
    private let disposeBag = DisposeBag()

    // Inputs
    public let username = PublishRelay<String>()
    public let password = PublishRelay<String>()
    public let rememberMe = PublishRelay<Bool>()
    public let loginButtonTap = PublishRelay<Void>()

    // Outputs
    public let message = BehaviorRelay<String>(value: "")

    public init(validator: ValidatorType, apiClient: APIClientType, credentialStore: CredentialStoreType) {
        let credential: Observable<Credential> = Observable
            .combineLatest(username, password)
            .map { username, password in
                Credential(username: username, password: password)
            }
            .share()

        let isCredentialValid = credential
            .map { validator.validate(credential: $0) }.share()

        let validCredential = credential
            .withLatestFrom(isCredentialValid) { ($0, $1) }
            .filter { _, isValid in isValid }
            .map { credential, _ in credential }
            .share()

        loginButtonTap
            .withLatestFrom(isCredentialValid)
            .filter { isValid in !isValid }
            .map { _ in "invalid" }
            .bind(to: message)
            .disposed(by: disposeBag)

        let shouldStoreCredential = loginButtonTap.withLatestFrom(rememberMe).share()

        let apiCall = loginButtonTap
            .withLatestFrom(validCredential)
            .do(onNext: { [message] _ in message.accept("loading") })
            .flatMap { credential in
                apiClient.login(credential: credential)
            }
            .share()

        let didAPICallSuccess = apiCall
            .map { true }
            .catchErrorJustReturn(false)
            .share()

        didAPICallSuccess
            .map { $0 ? "success" : "error" }
            .bind(to: message)
            .disposed(by: disposeBag)

        didAPICallSuccess
            .withLatestFrom(shouldStoreCredential) { ($0, $1) }
            .filter { didAPICallSuccess, rememberMe in didAPICallSuccess && rememberMe }
            .withLatestFrom(validCredential)
            .subscribe(onNext: { credential in
                credentialStore.save(credential: credential)
            })
            .disposed(by: disposeBag)
    }
}
