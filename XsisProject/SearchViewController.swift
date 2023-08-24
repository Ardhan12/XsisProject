//
//  DetailMovieViewController.swift
//  XsisProject
//
//  Created by Arief Ramadhan on 23/08/23.
//

import Foundation
import UIKit

let headers = [
      "accept": "application/json",
      "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI2ZTZkNGI5NDEyNDBjYzkzMDU3ODczN2VhNTBiMTU1YyIsInN1YiI6IjYzYTMyNTU4YmU2ZDg4MDA4NGVkOTc1MyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.Sa9uPvGIZMgUNU-1F-tTU6UGUFG51HEDV5lUuRqGmPQ"
    ]

let imageBaseURL = "https://image.tmdb.org/t/p/w500"

class SearchViewController: UIViewController {
    
    var movies: [ResultMovie] = []
    var filteredMovies: [ResultMovie] = [] // Filtered movies based on search query
    var isSearching = false
    let searchBar = UISearchBar()
    var allButton: UIButton?
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor(named: "FFIHome")
        collectionView.register(ImageCardCell.self, forCellWithReuseIdentifier: ImageCardCell.reuseIdentifier)
        return collectionView
    }()
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = UIColor(named: "FFIBackground")
        view.backgroundColor = .yellow
        //        self.navigationController?.setNavigationBarHidden(true, animated: true)
        setupSearchBar()
        setupCollectionView()
        fetchAPI()
    }
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    // MARK: - search setup
    func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Cari berdasarkan judul atau pemain"
        //        searchBar.backgroundImage = UIImage()
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = .white
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            //            textField.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            textField.backgroundColor = .clear
            textField.layer.cornerRadius = 10
            textField.clipsToBounds = true
            textField.textColor = .white
            let clearButton = UIButton(type: .custom)
            clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            clearButton.tintColor = .white
            clearButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 8)
            clearButton.addTarget(self, action: #selector(clearSearchText), for: .touchUpInside)
            textField.rightView = clearButton
            textField.rightViewMode = .whileEditing
        }
        navigationItem.titleView = searchBar
    }
    @objc func clearSearchText() {
        if let searchBar = navigationItem.titleView as? UISearchBar {
            searchBar.text = nil
            searchBar.resignFirstResponder()
            searchBar.showsCancelButton = false
            isSearching = false
            filteredMovies.removeAll()
            collectionView.reloadData()
        }
    }
    func fetchAPI() {
        
            if let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?language=en-US&page=1") {
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.allHTTPHeaderFields = headers
        
                let session = URLSession.shared
                let dataTask = session.dataTask(with: request) { [self] data, response, error in
                    if let error = error {
                        print(error)
                    } else if let httpResponse = response as? HTTPURLResponse {
                        print(httpResponse)
        
                        if let data = data {
                             do {
                                 let decoder = JSONDecoder()
                                 let response = try decoder.decode(Movie.self, from: data)
                                 movies = response.results
                                 DispatchQueue.main.async {
                                     self.collectionView.reloadData()
                                 }
//                                 print(movies)
                             } catch {
                                 print(error)
                             }
                        }
                    }
                }
        
                dataTask.resume()
            }
    }
}
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredMovies.removeAll()
            collectionView.reloadData()
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text, !searchText.isEmpty {
            filteredMovies = movies.filter { $0.title.lowercased().contains(searchText.lowercased()) }
            isSearching = true
            collectionView.reloadData()
        }
    }
}
// MARK: - UICollectionViewDataSource
extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearching ? filteredMovies.count : movies.count
        //        return movies.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCardCell.reuseIdentifier, for: indexPath) as! ImageCardCell
        let movie = isSearching ? filteredMovies[indexPath.item] : movies[indexPath.item]
        
        cell.configure(with: movie)
        return cell
    }
}
// MARK: - UICollectionViewDelegateFlowLayout
extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16
        let width = (collectionView.frame.width - padding*4) / 3
        return CGSize(width: width, height: 150)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = movies[indexPath.row]
        let vc = DetailMovieViewController()
        vc.fetchData(movieID: movie.id)
        vc.fetchDataVideo(movieID: movie.id)
        vc.modalPresentationStyle = .popover
        self.present(vc, animated: true)
    }
}

class ImageCardCell: UICollectionViewCell {
    static let reuseIdentifier = "FFImageCardCell1"

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with data: ResultMovie) {
        // Update the UI elements using the data provided
        titleLabel.text = data.title
        if let imageURL = URL(string: imageBaseURL + "/" + data.posterPath) {
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: imageURL),
                   let image = UIImage(data: imageData) {
                    DispatchQueue.main.async { [self] in
                        imageView.image = image
                    }
                }
            }
        }
    }

    private func setupSubviews() {
        contentView.addSubview(imageView)
        imageView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
}
