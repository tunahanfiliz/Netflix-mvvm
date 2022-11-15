//
//  SearchResultViewController.swift
//  Netflix
//
//  Created by Ios Developer on 10.11.2022.
//

import UIKit

protocol SearchResultViewControllerDelegate:AnyObject{
    func SearchResultViewControllerDidTapItem(_ viewModel:TitleDetailViewModel)
}


class SearchResultViewController: UIViewController {
    
    
    public var titles:[Title] = [Title]() //public yapma sebebim searchviewcontrollerin  extension SearchResultViewController: UISearchResultsUpdating kısmında kullanabilmem
    
    
    public weak var delegate:SearchResultViewControllerDelegate?
    

    public let searchResultsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 3 - 10 , height: 200) // UIScreen.main.bounds.width  her telefona ayrı boyut
        layout.minimumInteritemSpacing = 0  
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TitleCollectionViewCell.self, forCellWithReuseIdentifier: TitleCollectionViewCell.identifier)
        collectionView.backgroundColor = .systemBackground
     
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemRed
        view.addSubview(searchResultsCollectionView)
        
        searchResultsCollectionView.dataSource = self
        searchResultsCollectionView.delegate = self
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchResultsCollectionView.frame = view.bounds
    }
    
    

}

extension SearchResultViewController: UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionViewCell.identifier, for: indexPath) as? TitleCollectionViewCell else{return UICollectionViewCell() }
        let title = titles[indexPath.row]
        cell.configure(with: title.poster_path ?? "")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let title = titles[indexPath.row]
        let titleName = title.original_title ?? ""
        
        APICaller.shared.getMovie(with: titleName) { [weak self] result in
            switch result{
            case .success(let videoElement):
                self?.delegate?.SearchResultViewControllerDidTapItem(TitleDetailViewModel(title: titleName, youtubeView: videoElement, titleOverview: title.overview ?? ""))
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
}
