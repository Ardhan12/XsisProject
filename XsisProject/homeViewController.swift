//
//  testView.swift
//  XsisProject
//
//  Created by Arief Ramadhan on 24/08/23.
//

import Foundation
import UIKit

class HomePageViewController: UIViewController {
    
    var genres: [GenreMovie] = []
    var movies: [Results] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .yellow
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    private let collectionViewMovies: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor(named: "FFIHome")
        collectionView.isScrollEnabled = true
        collectionView.register(ContainerCardMovie.self, forCellWithReuseIdentifier: ContainerCardMovie.reuseIdentifier)
        return collectionView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .yellow
        return scrollView
    }()
    
    private let contentView: UIView = {
       let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .yellow
        return contentView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchList()
        fetchMovieCarousel()
        setupScrollView()
        rightNavigation()
    }
    
    private func setupScrollView() {
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let scrollContentGuide = scrollView.contentLayoutGuide
        let scrollFrameGuide = scrollView.frameLayoutGuide
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollContentGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollContentGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollContentGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollContentGuide.bottomAnchor),
            
            contentView.leadingAnchor.constraint(equalTo: scrollFrameGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollFrameGuide.trailingAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 3000),
            
        ])
    }
    
    func setupUI() {
        view.addSubview(contentView)
        contentView.addSubview(tableView)
        contentView.addSubview(collectionViewMovies)
        collectionViewMovies.dataSource = self
        collectionViewMovies.delegate = self
        
        NSLayoutConstraint.activate([
            collectionViewMovies.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 18),
            collectionViewMovies.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionViewMovies.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionViewMovies.heightAnchor.constraint(equalToConstant: 250),
            
            tableView.topAnchor.constraint(equalTo: collectionViewMovies.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(GenreTableViewCell.self, forCellReuseIdentifier: "GenreTableViewCell")
    }
    
    func fetchList() {
        if let url = URL(string: "https://api.themoviedb.org/3/genre/movie/list?language=en") {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    print(error)
                } else if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let response = try decoder.decode(MovieList.self, from: data)
                            // Handle the JSON response here
                        self.genres = response.genres
                        DispatchQueue.main.async { [self] in
                            print(genres)
                            tableView.reloadData()
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            
            dataTask.resume()
        }
    }
    
    private func rightNavigation() {
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        btn1.tintColor = .black
        btn1.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        btn1.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        self.navigationItem.setRightBarButton(item1, animated: true)
    }
    @objc func searchTapped() {
        let vc = SearchViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func fetchMovieCarousel() {
        
            if let url = URL(string: "https://api.themoviedb.org/3/movie/top_rated?language=en-US&page=1") {
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
                                 let response = try decoder.decode(Movies.self, from: data)
                                 movies = response.results
                                 DispatchQueue.main.async {
                                     self.collectionViewMovies.reloadData()
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
    
    func fetchDetailList(id: Int, completion: @escaping (Result<MovieListDetail, Error>) -> Void) {
        if let url = URL(string: "https://api.themoviedb.org/3/list/\(id)?language=en-US") {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    print(error)
                } else if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let response = try decoder.decode(MovieListDetail.self, from: data)
                        // Call the completion handler with the response data
                        DispatchQueue.main.async {
                            completion(.success(response))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
            
            dataTask.resume()
        }
    }

}

extension HomePageViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return genres.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GenreTableViewCell", for: indexPath) as! GenreTableViewCell
        
        let detail = genres[indexPath.section].id
        cell.delegate = self
        fetchDetailList(id: detail) { result in
            switch result {
            case .success(let movie):
                cell.configure(with: movie.items)
            case .failure(let error):
                print(error.localizedDescription)
                print("gada data bos")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .lightGray
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = genres[section].name
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
}

extension HomePageViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContainerCardMovie.reuseIdentifier, for: indexPath) as! ContainerCardMovie
        
        let movie = movies[indexPath.item]
        
        cell.configure(with: movie)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomePageViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 340, height: 180)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = movies[indexPath.row]
        let vc = DetailMovieViewController()
        vc.fetchData(movieID: movie.id)
        vc.modalPresentationStyle = .popover
        self.present(vc, animated: true)
    }

}
extension HomePageViewController: CardTableViewCellDelegate {
    func CardTableViewCellDidTapCell(_ movie: Item) {
        DispatchQueue.main.async {
            let vc = DetailMovieViewController()
            vc.fetchData(movieID: movie.id)
            vc.fetchDataVideo(movieID: movie.id)
            vc.modalPresentationStyle = .popover
            self.present(vc, animated: true)
        }
    }
}

protocol CardTableViewCellDelegate: AnyObject {
    func CardTableViewCellDidTapCell(_ movie: Item)
}
// Implement UICollectionViewDataSource and UICollectionViewDelegateFlowLayout
// Similar to the previous example

class GenreTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var delegate: CardTableViewCellDelegate?
    var item: [Item] = [Item]()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: "MovieCollectionViewCell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with item: [Item]){
        self.item = item
//        print(self.images)
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return the number of movies for each genre
        return item.count // Replace with your actual data
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as! MovieCollectionViewCell
        
        // Configure the cell with movie poster image
        // You might use your data source to retrieve the appropriate image
        let image = item[indexPath.item]
        
        if let imageURL = URL(string: imageBaseURL + "/" + image.posterPath) {
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: imageURL),
                   let image = UIImage(data: imageData) {
                    DispatchQueue.main.async { [self] in
                        cell.posterImageView.image = image
                    }
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth: CGFloat = 90
        let itemHeight: CGFloat = 150
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = item[indexPath.row]
//        let vc = DetailMovieViewController()
//        vc.fetchData(movieID: movie.id)
        delegate?.CardTableViewCellDidTapCell(movie)
    }
}


class MovieCollectionViewCell: UICollectionViewCell {

    let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(posterImageView)
        
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ContainerCardMovie: UICollectionViewCell {
    static let reuseIdentifier = "ContainerCardMovie"
    
    private let container: UIView = {
       let container = UIView()
        container.layer.cornerRadius = 20
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.darkGray.cgColor
        container.backgroundColor = .lightGray
        container.translatesAutoresizingMaskIntoConstraints = false
        
        return container
    }()

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
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    private let desc: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with data: Results) {
        // Update the UI elements using the data provided
        titleLabel.text = data.title
        desc.text = data.overview
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
        contentView.addSubview(container)
        container.addSubview(imageView)
        container.addSubview(titleLabel)
        container.addSubview(desc)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            container.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            container.heightAnchor.constraint(equalToConstant: 200),
            container.widthAnchor.constraint(equalToConstant: contentView.frame.size.width - 20),
            
            imageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            imageView.heightAnchor.constraint(equalToConstant: 150),
            imageView.widthAnchor.constraint(equalToConstant: 90),

            titleLabel.topAnchor.constraint(equalTo: imageView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            desc.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            desc.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            desc.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            desc.heightAnchor.constraint(equalToConstant: 130),
        ])
    }
}
