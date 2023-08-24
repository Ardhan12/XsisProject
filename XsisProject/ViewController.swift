//
//  ViewController.swift
//  XsisProject
//
//  Created by Arief Ramadhan on 23/08/23.
//

import UIKit

class ViewController: UIViewController {

    var List: [GenreMovie] = []
    let stackView = UIStackView()
    let scrollViewStack = UIScrollView()
    let containerPoster = UIView()
    let imageBg = UIImageView()
    var movies: [Results] = []
    
    
    private let collectionView: UICollectionView = {
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
        scrollView.backgroundColor = .white
        return scrollView
    }()
    
    private let contentView: UIView = {
       let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .white
        return contentView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .red
        setupScrollView()
        setupCollectionView()
        rightNavigation()
        fetchList()
        fetchMovieCarousel()
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
                        self.List = response.genres
                        DispatchQueue.main.async { [self] in
                            print(List)
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            
            dataTask.resume()
        }
    }
    
    func detailList(listId: Int) {
        if let url = URL(string: "https://api.themoviedb.org/3/list/\(listId)/language=en-US") {
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
                        self.List = response.genres
                        DispatchQueue.main.async { [self] in
                            print(List)
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            
            dataTask.resume()
        }
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
            contentView.heightAnchor.constraint(equalToConstant: 1000),
            
        ])
    }
    
    private func setupCollectionView() {
        
        contentView.addSubview(collectionView)
        contentView.addSubview(containerPoster)
        containerPoster.addSubview(imageBg)
        contentView.addSubview(scrollViewStack)
        
        imageBg.translatesAutoresizingMaskIntoConstraints = false
        imageBg.image = UIImage(named: "FFIHomeItemClear")
        imageBg.layer.cornerRadius = 20
        imageBg.layer.masksToBounds = true
        imageBg.contentMode = .scaleToFill
        
        
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        
        scrollViewStack.translatesAutoresizingMaskIntoConstraints = false
        scrollViewStack.showsHorizontalScrollIndicator = false
        
        scrollViewStack.addSubview(stackView)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        containerPoster.layer.cornerRadius = 20
        containerPoster.layer.borderWidth = 1
        containerPoster.layer.borderColor = UIColor.darkGray.cgColor
        containerPoster.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            collectionView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 18),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 250),
            
            containerPoster.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 12),
            containerPoster.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            containerPoster.heightAnchor.constraint(equalToConstant: 220),
            containerPoster.widthAnchor.constraint(equalToConstant: view.frame.size.width - 30),
            
            imageBg.topAnchor.constraint(equalTo: containerPoster.topAnchor),
            imageBg.leadingAnchor.constraint(equalTo: containerPoster.leadingAnchor),
            imageBg.trailingAnchor.constraint(equalTo: containerPoster.trailingAnchor),
            imageBg.bottomAnchor.constraint(equalTo: containerPoster.bottomAnchor),
            
            
        ])
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


// MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {

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

extension ViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16
        let width = collectionView.frame.width - 20
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

//class ContainerCardMovie: UICollectionViewCell {
//    static let reuseIdentifier = "ContainerCardMovie"
//    
//    private let container: UIView = {
//       let container = UIView()
//        container.layer.cornerRadius = 20
//        container.layer.borderWidth = 1
//        container.layer.borderColor = UIColor.darkGray.cgColor
//        container.backgroundColor = .lightGray
//        container.translatesAutoresizingMaskIntoConstraints = false
//        
//        return container
//    }()
//
//    private let imageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        imageView.layer.cornerRadius = 20
//        return imageView
//    }()
//
//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
//        label.textColor = .black
//        label.numberOfLines = 0
//        label.textAlignment = .left
//        return label
//    }()
//
//    private let desc: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.boldSystemFont(ofSize: 12)
//        label.textColor = .black
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.numberOfLines = 0
//        return label
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        setupSubviews()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func configure(with data: Results) {
//        // Update the UI elements using the data provided
//        titleLabel.text = data.title
//        desc.text = data.overview
//        if let imageURL = URL(string: imageBaseURL + "/" + data.posterPath) {
//            DispatchQueue.global().async {
//                if let imageData = try? Data(contentsOf: imageURL),
//                   let image = UIImage(data: imageData) {
//                    DispatchQueue.main.async { [self] in
//                        imageView.image = image
//                    }
//                }
//            }
//        }
//    }
//
//    private func setupSubviews() {
//        contentView.addSubview(container)
//        container.addSubview(imageView)
//        container.addSubview(titleLabel)
//        container.addSubview(desc)
//
//        NSLayoutConstraint.activate([
//            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
//            container.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            container.heightAnchor.constraint(equalToConstant: 200),
//            container.widthAnchor.constraint(equalToConstant: contentView.frame.size.width - 20),
//            
//            imageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
//            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
//            imageView.heightAnchor.constraint(equalToConstant: 150),
//            imageView.widthAnchor.constraint(equalToConstant: 90),
//
//            titleLabel.topAnchor.constraint(equalTo: imageView.topAnchor),
//            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
//            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            
//            desc.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
//            desc.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
//            desc.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            desc.heightAnchor.constraint(equalToConstant: 130),
//        ])
//    }
//}
