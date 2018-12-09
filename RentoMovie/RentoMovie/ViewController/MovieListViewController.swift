//
//  MovieListViewControllerViewController.swift
//  RentoMovie
//
//  Created by Shailesh.Chandavar on 06/12/18.
//  Copyright © 2018 Shailesh.Chandavar. All rights reserved.
//

import UIKit

//MovieListViewController is used to show list of movies.
//when user taps on any movie it card will expand to show whole synopsis.

class MovieListViewController: UIViewController {
    @IBOutlet weak var movieListCollectionView: UICollectionView!
    var movieListPresenter = MovieListPresenter()
    var cellSelected: IndexPath?
    var refreshControl: UIRefreshControl?

    
    var movies: [Movie]? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else {return}
                self.movieListCollectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
   
    private func configureView() {
        navigationController?.navigationBar.prefersLargeTitles = true
        movieListCollectionView.dataSource = self
        movieListCollectionView.delegate = self
        movieListPresenter.configureCollectionView(collectionView: movieListCollectionView, containerController: self)
        populateMovieData()
        configureRefreshControl()
    }
    
    
    private func populateMovieData() {
        movieListPresenter.fetchMovieList { [weak self] (movies) in
            guard let `self` = self else {return}
            DispatchQueue.main.async {
               self.refreshControl?.endRefreshing()
            }
            
            self.movies = movies
        }
    }
    
    private func configureRefreshControl() {
        refreshControl = UIRefreshControl.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        refreshControl?.triggerVerticalOffset = 50.0
        refreshControl?.addTarget(self, action: #selector(self.paginate), for: .valueChanged)
        movieListCollectionView.bottomRefreshControl = refreshControl
    }

    
    @objc func paginate() {
         populateMovieData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        movieListPresenter.cachedCellSize = nil
        movieListCollectionView.reloadData()
    }
}

// MARK: CollectionView-DataSource
extension MovieListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (movies?.count ?? 0)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
            "movieListCell", for: indexPath) as! MovieListCollectionViewCell
        cell.configureWithMovie(movie: movies?[indexPath.row] ?? Movie())
        return cell
    }
}

extension MovieListViewController: UICollectionViewDelegateFlowLayout {
  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return movieListPresenter.sizeForItemInTraitCollection(traitCollection: view.traitCollection.horizontalSizeClass, screenWidth: UIScreen.main.bounds.width, movieInfo: movies?[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Collapse Already expanded cell
        
        if cellSelected == indexPath {
            return
        }
        
        
        if let cellSelected = cellSelected, let selctedMovie = movies?.remove(at: cellSelected.row) {
            
            selctedMovie.synopsisShown = false
            movies?.insert(selctedMovie, at: cellSelected.row)
            
            collectionView.performBatchUpdates({
                self.cellSelected = nil
                collectionView.deleteItems(at: [cellSelected])
                collectionView.insertItems(at: [cellSelected])
                collectionView.deleteItems(at: [indexPath])
                collectionView.insertItems(at: [indexPath])
            }, completion: { (completed) in
              
            })
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let `self` = self else {return}
            guard let movieToBeSelected = self.movies?.remove(at: indexPath.row) else {return}
            
            self.cellSelected = indexPath
            movieToBeSelected.synopsisShown = true
            self.movies?.insert(movieToBeSelected, at: indexPath.row)
           
            collectionView.performBatchUpdates({
                collectionView.deleteItems(at: [indexPath])
                collectionView.insertItems(at: [indexPath])
            }, completion: { (completed) in
            })
        }
    
    }
}




