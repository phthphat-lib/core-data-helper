# CoreData Helper

Workwith `NSPersistentContainer` so it require minimum iOS version is 10.0

## Sample method
See example project for more
### Fetch
```swift
func loadUser() {
    container.fetch(on: .background) { (result: Result<[User], Error>) in
        switch result {
        case .success(let users):
            print(users.map({ $0.name }))
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
}
```

### Insert
```swift
func addUser(name: String, birthday: Date) {
    container.insert(on: .background, setUpEntity: { (user: User) in
        user.name = name
        user.birthday = birthday
    }) { err in
        print(err?.localizedDescription)
    }
}
```

### Delete
```swift
func deleteUser(isContained name: String) {
    container.delete(on: .background, whichInclude: { (user: User) in
        return user.name == name
    }) { err in
        print(err?.localizedDescription)
    }
}
```

## Issue
Each closure we should manual provide type, otherwise xcode don't know what entity we want to fetch. I'll try to improve it later
