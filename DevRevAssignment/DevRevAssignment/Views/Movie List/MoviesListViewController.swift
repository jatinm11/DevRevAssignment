//
//  MoviesListViewController.swift
//  DevRevAssignment
//
//  Created by Jatin Menghani on 09/02/24.
//

import UIKit
import Marshmellow

class MoviesListViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentView: DRVSegmentedControl!

    // MARK: - Properties
    
    private let viewModel = MoviesListViewModel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupCollectionView()
        setupScrollView()
        setupActivityIndicator()
        fetchMovieListFor(endpoint: .popular)
    }
    
    // MARK: - Setup Methods
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "FooterView")
    }
    
    func setupScrollView() {
        segmentView.delegate = self
        segmentView.setButtonTitles(buttonTitles: ["Popular", "Top Rated"])
    }
    
    func setupActivityIndicator() {
        activityIndicator.startAnimating()
        activityIndicator.color = .black
        activityIndicator.hidesWhenStopped = true
        
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
    }
    
    // MARK: - Data
    private func fetchMovieListFor(endpoint: APIEndpoint) {
        viewModel.fetchMovieListFor(endpoint: endpoint) { [weak self] result in
            guard let self = self else { return }
            self.handleFetchResult(result)
        }
    }
    
    private func handleFetchResult(_ result: Result<[Movie], MellowError>) {
        switch result {
        case .success:
            DispatchQueue.main.async {
                if self.activityIndicator.isAnimating { self.activityIndicator.stopAnimating() }
                self.collectionView.reloadData()
            }
        case .failure(let error):
            print(error.localizedDescription)
            DispatchQueue.main.async {
                self.showErrorToast(message: "Unable to fetch at the moment.")
            }
        }
    }
    
    @objc func loadMoreMovies() {
        viewModel.loadMoreMoviesIfNeeded(endpoint: segmentView.selectedIndex == 0 ? .popular : .topRated) { result in
            DispatchQueue.main.async {
                self.handleFetchResult(result)
            }
        }
    }
}

// MARK: - CollectionView Methods

extension MoviesListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfMovies()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieListCell", for: indexPath) as! MovieListCell
        cell.configureCellWith(movieItem: viewModel.movie(at: indexPath.row))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width / 2) - 10, height: 340)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItemAt(indexPath: indexPath, presentingViewController: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 65)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionFooter {
            
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FooterView", for: indexPath)
            
            if viewModel.movieList.count > 0 {
                let button = UIButton()
                button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
                button.frame = CGRect(x: (footerView.frame.width - 130) / 2, y: (footerView.frame.height - 40) / 2, width: 130, height: 40)
                button.setTitle("Load More", for: .normal)
                button.setTitleColor(.white, for: .normal)
                button.backgroundColor = .black
                button.layer.cornerRadius = 7
                button.addTarget(self, action: #selector(loadMoreMovies), for: .touchUpInside)
                
                footerView.addSubview(button)
            }

            return footerView
        } 
        else {
            return UICollectionReusableView()
        }
    }
}

// MARK: - Segment Delegate

extension MoviesListViewController: DRVSegmentedControlDelegate {
    func segmentDidChange(to index: Int) {
        switch index {
        case 0:
            viewModel.didChangeSegmentTo(endPoint: .popular, completion: handleFetchResult(_:))
        case 1:
            viewModel.didChangeSegmentTo(endPoint: .topRated, completion: handleFetchResult(_:))
        default:
            return
        }
        
        self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
}

// MARK: - Initializer

extension MoviesListViewController {
    static func controller() -> UIViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MoviesListViewController") as! MoviesListViewController
        return vc
    }
}
