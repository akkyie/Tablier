import Foundation

func asyncEcho(_ input: String, completion: @escaping (String) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [input] in
        completion(input)
    }
}
