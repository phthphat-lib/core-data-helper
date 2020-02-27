//
//  ViewController.swift
//  ExampleProject
//
//  Created by Lucas Pham on 2/27/20.
//  Copyright © 2020 phthphat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addUser(name: "abc", birthday: Date())
        addUser(name: "def", birthday: Date())
        addUser(name: "ghi", birthday: Date())
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.container.saveAllContexts()
        }
        
//        loadUser()
    }

    func addUser(name: String, birthday: Date) {
        container.insert(on: .background, setUpEntity: { (user: User) in
            user.name = name
            user.birthday = birthday
        }) { err in
            print(err?.localizedDescription)
        }
    }
    
    func loadUser() {
        container.fetch(on: .background) { (result: Result<[User], Error>) in
            switch result {
            case .success(let users):
                print(users.forEach({ $0.name }))
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func deleteUser(isContained name: String) {
        container.delete(on: .background, whichInclude: { (user: User) in
            return user.name == name
        }) { err in
            print(err?.localizedDescription)
        }
    }
    

}

