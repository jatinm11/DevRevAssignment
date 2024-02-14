//
//  MovieDetailsViewController.swift
//  DevRevAssignment
//
//  Created by Jatin Menghani on 09/02/24.
//

import UIKit
import Marshmellow

class MovieDetailsViewController: UIViewController, UIScrollViewDelegate {

    // MARK: - Outlets
    
    // Scroll View
    @IBOutlet weak var scrollView: UIScrollView!
    
    // Basic details
    @IBOutlet weak var moviePosterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var fictionReleaseDateLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    // Tagline
    @IBOutlet weak var taglineContainerView: UIView!
    @IBOutlet weak var taglineLabel: UILabel!
    
    // Stats
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var revenueLabel: UILabel!
    @IBOutlet weak var revenueIndicatorIcon: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
        
    // Cast Collection View
    @IBOutlet weak var collectionView: UICollectionView!
    
    // External
    @IBOutlet weak var imdbContainerView: UIView!
    @IBOutlet weak var imdbIcon: UIImageView!
    @IBOutlet weak var imdbLabel: UILabel!
    
    @IBOutlet weak var websiteContainerView: UIView!
    @IBOutlet weak var websiteIcon: UIImageView!
    @IBOutlet weak var websiteLabel: UILabel!
    
    // MARK: - Properties
    
    var movieId: Int!
    private var viewModel: MovieDetailsViewModel!
    private var viewTranslation = CGPoint(x: 0, y: 0)
        
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = MovieDetailsViewModel(movieId: self.movieId)
        
        setupViews()
        setupGestures()
        fetchData()
    }
    
    // MARK: - Setup Methods
    
    private func setupViews() {
        setupCollectionView()
        setupScrollView()
        self.overviewLabel.setLineSpacing(lineSpacing: 7)
        self.taglineLabel.setLineSpacing(lineSpacing: 7)
    }
    
    private func setupCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }

    private func setupScrollView() {
        self.scrollView.delegate = self
        self.scrollView.contentInset = UIEdgeInsets(top: (moviePosterImageView.frame.size.height) - 90, left: 0, bottom: 0, right: 0)
    }
    
    private func setupGestures() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleDismiss(sender:)))
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)
        
        let imdbGesture = UITapGestureRecognizer()
        imdbGesture.addTarget(self, action: #selector(imdbButtonTapped))
        imdbContainerView.addGestureRecognizer(imdbGesture)
        
        let websiteGesture = UITapGestureRecognizer()
        websiteGesture.addTarget(self, action: #selector(websiteButtonTapped))
        websiteContainerView.addGestureRecognizer(websiteGesture)
    }
    
    // MARK: - Data
    
    private func fetchData() {
        fetchMovieDetails()
        fetchCastList()
    }
    
    private func fetchMovieDetails() {
        viewModel.fetchMovieDetails { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.updateUI()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func fetchCastList() {
        viewModel.fetchCastList { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.showErrorToast(message: "Unable to fetch at the moment.")
                }
            }
        }
    }
    
    // MARK: - UI Update
    
    func updateUI() {        
        self.moviePosterImageView.fetchImageFromURL(urlString: viewModel.backdropPath() ?? "")
        self.titleLabel.text = viewModel.movieTitle()
        self.fictionReleaseDateLabel.text = "\(viewModel.movieGenres() ?? "") • \(viewModel.releaseDate() ?? "")"
        self.overviewLabel.text = viewModel.overview()
        
        self.taglineLabel.text = viewModel.tagline()
        self.budgetLabel.text = viewModel.budget()
        self.revenueLabel.text = viewModel.revenue()
        self.ratingLabel.text = viewModel.rating()
        self.runtimeLabel.text = viewModel.runtime()
        
        self.revenueLabel.textColor = viewModel.revenueTextColor()
        self.revenueIndicatorIcon.tintColor = viewModel.revenueTextColor()
        self.revenueIndicatorIcon.image = UIImage(systemName: viewModel.revenueIndicatorIconName()!)
        self.revenueIndicatorIcon.isHidden = viewModel.revenue() == "N/A"
    
        self.imdbLabel.textColor = viewModel.imdbId == nil ? .lightGray : .label
        self.imdbIcon.tintColor = viewModel.imdbId == nil ? .lightGray : .label
        
        self.websiteLabel.textColor = viewModel.movieHomepage == "" ? .lightGray : .label
        self.websiteIcon.tintColor = viewModel.movieHomepage == "" ? .lightGray : .label
    }
    
    // MARK: - Actions
    
    @objc func imdbButtonTapped() {
        viewModel.openIMDbPage()
    }
    
    @objc func websiteButtonTapped() {
        viewModel.openMovieWebsite()
    }
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

// MARK: - CollectionView Methods

extension MovieDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfCastMembers()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CastCell", for: indexPath) as! CastCell
        cell.configureCellWith(castItem: viewModel.cast(at: indexPath.row)) 
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width / 2) - 5, height: 50)
    }
}

// MARK: - Gesture Recognizer Delegate

extension MovieDetailsViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let scrollViewPanGestureRecognizer = otherGestureRecognizer as? UIPanGestureRecognizer,
            scrollViewPanGestureRecognizer.view is UIScrollView {
            return true
        }
        return false
    }
    
    private func roundTopCorners(radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.view.bounds,
                                    byRoundingCorners: [.topLeft, .topRight],
                                    cornerRadii: CGSize(width: radius, height: radius))

        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        self.view.layer.mask = maskLayer
    }

    @objc func handleDismiss(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            viewTranslation = sender.translation(in: view)
            if viewTranslation.y > 0 {
                roundTopCorners(radius: 20)
                let translationY = self.viewTranslation.y
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    let scale = 1 + (translationY / 150)
                    self.scrollView.transform = CGAffineTransform(translationX: 0, y: translationY)
                    self.moviePosterImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
                })
                
                if viewTranslation.y > 150 {
                    dismiss(animated: true, completion: nil)
                }
            }
        case .ended:
            if viewTranslation.y > 0 && viewTranslation.y > 100 {
                dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    self.scrollView.transform = .identity
                    self.moviePosterImageView.transform = .identity
                })
            }
        default:
            break
        }
    }
}

// MARK: - Initializer

extension MovieDetailsViewController {
    static func controller(movieId: Int) -> UIViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MovieDetailsViewController") as! MovieDetailsViewController
        vc.movieId = movieId
        return vc
    }
}
