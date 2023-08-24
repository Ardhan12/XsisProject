//
//  DetailMovieViewController.swift
//  XsisProject
//
//  Created by Arief Ramadhan on 24/08/23.
//

import Foundation
import UIKit
import AVKit

class DetailMovieViewController: UIViewController {
    
    let dismissButton = UIButton()
    var movie: DetailMovie?
    var VideoMovie: [VideoResult]?
    private var playerViewController: AVPlayerViewController?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupView()
        setupUI()
    }
    
    func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(posterImageView)
        view.addSubview(overviewLabel)
        posterImageView.addSubview(playButton)
        
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            
            posterImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            posterImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            posterImageView.widthAnchor.constraint(equalToConstant: 340),
            posterImageView.heightAnchor.constraint(equalToConstant: 200),
            
            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            titleLabel.widthAnchor.constraint(equalToConstant: 100),
            
            overviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            overviewLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            overviewLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            
            playButton.centerXAnchor.constraint(equalTo: posterImageView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: posterImageView.centerYAnchor),
            
        ])
    }

    
    func fetchData(movieID: Int) {
        if let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieID)?language=en-US") {
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
                        let movieDetail = try decoder.decode(DetailMovie.self, from: data)
                        
                        // Use the movieDetail struct to populate your UI or do other tasks
                        DispatchQueue.main.async {[self] in
                            self.movie = movieDetail
                            updateUI(with: movieDetail)
                        }
                        
                        
                        print(movieDetail)
                    } catch {
                        print(error)
                    }
                }
            }
            
            dataTask.resume()
        }
    }
    
    func fetchDataVideo(movieID: Int) {
        if let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieID)/videos?language=en-US") {
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
                        let video = try decoder.decode(VideoDetail.self, from: data)
                        
                        // Use the movieDetail struct to populate your UI or do other tasks
                        DispatchQueue.main.async {[self] in
                            self.VideoMovie = video.results
                        }
                        
                        print(video)
                    } catch {
                        print(error)
                    }
                }
            }
            
            dataTask.resume()
        }
    }
        
    func updateUI(with movie: DetailMovie) {
        DispatchQueue.main.async {[self] in
            titleLabel.text = movie.title
            overviewLabel.text = movie.overview
            if let imageURL = URL(string: imageBaseURL + "/" + movie.backdropPath) {
                DispatchQueue.global().async {
                    if let imageData = try? Data(contentsOf: imageURL),
                       let image = UIImage(data: imageData) {
                        DispatchQueue.main.async { [self] in
                            posterImageView.image = image
                        }
                    }
                }
            }
        }
    }

    func playVideo(withKey videoKey: String) {
        guard let videoURL = URL(string: "https://www.youtube.com/watch?v=\(videoKey)") else {
            return
        }

        let player = AVPlayer(url: videoURL)
        playerViewController = AVPlayerViewController()
        playerViewController?.player = player

        if let playerViewController = playerViewController {
            present(playerViewController, animated: true) {
                player.play()
            }
        }
    }

    @objc func playButtonTapped(_ sender: UIButton) {
        guard let selectedMovie = VideoMovie, let videoKey = selectedMovie.first?.key else {
            return
        }
        print("ini movie ke tap bro: \(videoKey)")
        playVideo(withKey: videoKey)
    }
    func setupView() {
        
        dismissButton.setImage(UIImage(systemName: "x.circle.fill"), for: .normal)
        dismissButton.tintColor = .darkGray
        dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dismissButton)
        
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc func dismissButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
