//
//  SearchViewController.swift
//  Netflix
//
//  Created by Ios Developer on 7.11.2022.
//

import UIKit

class SearchViewController: UIViewController {

    
    private var titles:[Title] = [Title]()
    
    private let discoverTable:UITableView = {
      let table = UITableView()
        table.register(UpcomingTableViewCell.self, forCellReuseIdentifier: UpcomingTableViewCell.identifier)
        
        return table
        
    }()
    
    
    private let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: SearchResultViewController())
        controller.searchBar.placeholder = "Search to Movie or Tv show"
        controller.searchBar.searchBarStyle = .minimal
        return controller
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        
        view.backgroundColor = .systemBackground
        view.addSubview(discoverTable)
        
        discoverTable.delegate = self
        discoverTable.dataSource = self
        
        navigationItem.searchController = searchController
        navigationController?.navigationBar.tintColor = .white // cancel beyaz olsun 
        
        fetchDiscoverMovies()
        
        searchController.searchResultsUpdater = self // veri arama şeyini yapılandırma gerekiyor UISearchResultsUpdating protocolunu baslatmamız gerekiyor
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        discoverTable.frame = view.bounds
    }
    
    private func fetchDiscoverMovies(){
        APICaller.shared.getDiscoverMovies { [weak self] result in
            switch result {
            case .success(let title):
                self?.titles = title
                DispatchQueue.main.async {
                    self?.discoverTable.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
                
            }
        }
    }
    

   

}

extension SearchViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UpcomingTableViewCell.identifier, for: indexPath) as? UpcomingTableViewCell else{return UITableViewCell()}
        
        let title = titles[indexPath.row]
        let model = TitleViewModel(titleName: title.original_name ?? title.original_title ?? "unknown name", posterURL: title.poster_path ?? "")
        cell.configure(with: model)
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let title = titles[indexPath.row]
        guard let titleName = title.original_title ?? title.original_name else {return}
        
        APICaller.shared.getMovie(with: titleName) { [weak self] result in
            switch result{
            case .success(let videoElement):
                DispatchQueue.main.async {
                    let vc = TitleDetailViewController()
                    vc.configure(with: TitleDetailViewModel(title: titleName, youtubeView: videoElement, titleOverview: title.overview ?? ""))
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
                
    }
   
}

extension SearchViewController: UISearchResultsUpdating,SearchResultViewControllerDelegate{
    func updateSearchResults(for searchController: UISearchController) { // arama sonuçlarını güncelle. arama çubugundan query i almamız gerekiyor
         // metnin gönderilmeye hazır oldugunu anlamak için karakterleri beyaz boşlukta kırpma . her beyaz bosluk kesilcek. boş olmamalı. sunucu aramasında sonucun 3 den fazla olmamasını sağlamak.
        
        let searchBar = searchController.searchBar
        guard let query = searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              query.trimmingCharacters(in: .whitespaces).count >= 1,
              let resultsController = searchController.searchResultsController as? SearchResultViewController else {return}
        
        resultsController.delegate = self // protokolu baglamak için burdan ulaştık
        
        
        APICaller.shared.search(with: query) { result in   // BURDA TİTLEYE BİLGİLERİ YUKLEDİK 
            DispatchQueue.main.async {
                switch result {
                case .success(let titles):
                    resultsController.titles = titles
                    resultsController.searchResultsCollectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func SearchResultViewControllerDidTapItem(_ viewModel: TitleDetailViewModel) { //searchresult ile searcı delegeteyle bagladık
       
        DispatchQueue.main.async {[weak self] in
            let vc = TitleDetailViewController()
            vc.configure(with: viewModel)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
}
