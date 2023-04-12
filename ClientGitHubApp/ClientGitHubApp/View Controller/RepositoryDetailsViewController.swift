//
//  RepositoryDetailsViewController.swift
//  ClientGitHubApp
//
//  Created by Yugandhara Bodhekar on 12/04/23.
//

import UIKit

 final class RepositoryDetailsViewController: UIViewController {
     
     // MARK: - Variable
    
    var repoList: Repository?
    
    @IBOutlet weak var idTextField: UITextField!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var isPrivateTextField: UITextField!
    
    @IBOutlet weak var createdAtTextField: UITextField!
    
    @IBOutlet weak var updatedAtTextField: UITextField!
    
    @IBOutlet weak var languageTextField: UITextField!
    
     // MARK: - Lifecycle
     
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Repository Details"
        
        guard let repoDetails = repoList else {
            return
        }
        idTextField.text = "\(repoDetails.id)"
        nameTextField.text = repoDetails.name
        descriptionTextField.text = repoDetails.description
        isPrivateTextField.text = "\(repoDetails.isPrivate)"
        createdAtTextField.text = "\(repoDetails.createdAt)"
        updatedAtTextField.text = "\(repoDetails.updatedAt)"
        languageTextField.text = repoDetails.language
    }
}
