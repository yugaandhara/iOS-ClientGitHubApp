//
//  RepositoriesListViewController.swift
//  ClientGitHubApp
//
//  Created by Yugandhara Bodhekar on 07/04/23.
//

import UIKit

final class RepositoriesListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Variables And Properties
    
    private var repoList: [Repository] = []
    
    var githubDisplayName = ""
    
    var githubAccessToken = ""
    
    private let repoDataRequestHelper = RequesrHelper()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Repositories List"
        fetchRepoList()
    }
    
    // MARK: - Internal Methods
    
    private func fetchRepoList() {
        repoDataRequestHelper.getRepoData(accessToken: githubAccessToken) { [weak self] results, errorMessage in
            guard let self = self, let repoResults = results else {
                if !errorMessage.isEmpty {
                    print("Book Data API Error: " + errorMessage)
                }
                return
            }
            self.repoList = repoResults
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        repoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "repoListCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = repoList[indexPath.row].name
        cell.contentConfiguration = content
        return cell
    }
    
    // MARK: - Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showRepoDetails", sender: tableView)
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRepoDetails" {
            guard let indexPath = self.tableView.indexPathForSelectedRow as? NSIndexPath else { return }
            let repositoryDetailsViewController = segue.destination as? RepositoryDetailsViewController
            repositoryDetailsViewController?.repoList = repoList[indexPath.row] as Repository
        }
    }
}
