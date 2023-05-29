//
//  ViewController.swift
//  TestStoryboard
//
//  Created by Илья Мишин on 29.05.2023.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar?
    @IBOutlet weak var pictureCollectionView: UICollectionView?

    private var results: [Results] = []
    private var filteredResults: [Results] = []
    private var currentPage = 1
    private let cellSize = CGSize(width: UIScreen.main.bounds.width / 3.5, height: UIScreen.main.bounds.width / 3.5)
    private let searchCellSize = CGSize(width: UIScreen.main.bounds.width / 1.5, height: UIScreen.main.bounds.width / 2.5)
    private var isSearchActive = false

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchPictures()
    }

    // Fetches pictures from the API based on the query and current page
    private func fetchPictures(query: String? = nil) {
        APICaller.shared.getPictures(with: query, page: currentPage) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let results):
                if query != nil {
                    self.filteredResults.append(contentsOf: results)
                } else {
                    self.results.append(contentsOf: results)
                }
                self.reloadView()
            case .failure(let error):
                print("Failed to fetch search results: \(error)")
            }
        }
    }
    
    // Reloads the collection view, Invalidates the collection view layout and increments the current page
    private func reloadView() {
        DispatchQueue.main.async {
            self.pictureCollectionView?.reloadData()
            self.pictureCollectionView?.collectionViewLayout.invalidateLayout()
            self.currentPage += 1
        }
    }
}

// MARK: - Implement CollectionView methods -

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return isSearchActive ? searchCellSize : cellSize
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return isSearchActive ? filteredResults.count : results.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let pictureURL = isSearchActive ? filteredResults[indexPath.row].urls.small : results[indexPath.row].urls.small
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PictureCollectionViewCell.identifier, for: indexPath) as? PictureCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.backgroundColor = .systemBackground
        cell.configure(with: pictureURL)
        cell.deleteButton?.isHidden = !isSearchActive
        cell.deleteButton?.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
        cell.deleteButton?.tag = indexPath.row

        return cell
    }
    
    @objc func deleteButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        
        UIView.animate(withDuration: 0.3, animations: {
            self.filteredResults.remove(at: index)
            self.pictureCollectionView?.deleteItems(at: [IndexPath(item: index, section: 0)])
        }, completion: nil)
        
        // Update the delete button tags after deleting an item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let indexPaths = (0..<self.filteredResults.count).map { IndexPath(row: $0, section: 0) }
            self.pictureCollectionView?.reloadItems(at: indexPaths)
        }
    }

    // Presents the DisplayPictureViewController with the appropriate image URL
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fullScreenViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DisplayPictureViewController") as? DisplayPictureViewController
        fullScreenViewController?.imageURL = isSearchActive ? filteredResults[indexPath.row].urls.small : results[indexPath.row].urls.small
        fullScreenViewController?.modalPresentationStyle = .fullScreen
        fullScreenViewController?.modalTransitionStyle = .crossDissolve
        present(fullScreenViewController ?? self, animated: true, completion: nil)
    }

    // Fetches more pictures if the last item is displayed and the current page is less than or equal to 10
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastItem = isSearchActive ? filteredResults.count - 1 : results.count - 1
        if indexPath.item == lastItem {
            if currentPage <= 10 {
                fetchPictures()
            }
        }
    }
}

// MARK: - Implement Search Bar methods -

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredResults.removeAll()
        if searchText.isEmpty {
            isSearchActive = false
            self.pictureCollectionView?.collectionViewLayout.invalidateLayout()
            self.pictureCollectionView?.reloadData()
        }
        guard let query = searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty, query.trimmingCharacters(in: .whitespaces).count >= 3 else { return }
        isSearchActive = !searchText.isEmpty
        APICaller.shared.getPictures(with: query, page: currentPage) { result in
            switch result {
            case .success(let fetchedResult):
                self.filteredResults = fetchedResult
                DispatchQueue.main.async {
                    self.pictureCollectionView?.collectionViewLayout.invalidateLayout()
                    self.pictureCollectionView?.reloadData()
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
}
