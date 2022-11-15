//
//  HomeViewController.swift
//  Netflix
//
//  Created by Ios Developer on 7.11.2022.
//

import UIKit


enum Sections: Int {
    case TrendingMovies = 0
    case TrendingTV =  1
    case Popular = 2
    case Upcoming = 3
    case TopRated = 4
}



class HomeViewController: UIViewController {

    private var randomTrendingMovie: Title?
    private var headerView : HeroHeaderUIView?
    private var page:Int = 1
    let sectionTitles: [String] = ["Trendıng Movıes","Trendıng Tv","Popular","Upcomıng Movıes","Top Rated"]
    
    private let homeFeedTable: UITableView = {
       
        let table = UITableView(frame: .zero,style: .grouped)
        table.register(CollectionViewTableViewCell.self, forCellReuseIdentifier: CollectionViewTableViewCell.identifier)
        return table
        
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addSubview(homeFeedTable)
        homeFeedTable.delegate = self
        homeFeedTable.dataSource = self
        
        configureNavbar()
        
        headerView = HeroHeaderUIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 500))
        homeFeedTable.tableHeaderView = headerView
        
        //getTrendingMovies()
        
        configureHeroHeaderView()
        
        
        
        
    }
    
    private func configureHeroHeaderView(){
        APICaller.shared.getTrendingMovies { [weak self] result in
            switch result{
            case .success(let titles):
                
                let selectedTitle = titles.randomElement()
                self?.randomTrendingMovie = selectedTitle
                self?.headerView?.configure(with: TitleViewModel(titleName: selectedTitle?.original_name ?? "", posterURL: selectedTitle?.poster_path ?? ""))
                
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        homeFeedTable.frame = view.bounds
    }
    
    
    
    private func configureNavbar(){
        var image = UIImage(named: "n5")
        
        image = image?.withRenderingMode(.alwaysOriginal) // orjinal fotoyu koyduruyoruz
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: nil)
        
        navigationItem.rightBarButtonItems = [ // s ile bitiyor birden fazla buton eklemek için yani
            UIBarButtonItem(image: UIImage(systemName: "person"), style: .done, target: self, action: nil),
            UIBarButtonItem(image: UIImage(systemName: "play.rectangle"), style: .done, target: self, action: nil)
        ]
        
        navigationController?.navigationBar.tintColor = .white //sembollerin rengini beyaz yaotı
    }
    
    /*private func getTrendingMovies(){ bu alan cell lerin orda güncellendi
        APICaller.shared.getTrendingMovies { results in
            switch results{
            case .success(let movies):
                print(movies)
            case .failure(let error):
                print(error)
                
            }
        }
    }

    */

}

extension HomeViewController:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CollectionViewTableViewCell.identifier, for: indexPath) as? CollectionViewTableViewCell else {return UITableViewCell() }
        
        cell.delegate = self // collectionviewtableviewcell de ki protocole baglanıp delegeyi buraya çekmek için burdan ulaştık amacımız en altta delegeyi çekmektşi
        
        switch indexPath.section{
            
        case Sections.TrendingMovies.rawValue:
            APICaller.shared.getTrendingMovies { result in
                switch result{
                case .success(let titles):
                    cell.configure(with: titles)
                    
                case .failure(let error):
                    print(error)
                }
                
            }
        case Sections.TrendingTV.rawValue:
            APICaller.shared.getTrendingTvs { result in
                switch result{
                case .success(let title):
                    cell.configure(with: title)
                case .failure(let error):
                    print(error)
                }
            }
        case Sections.Popular.rawValue:
            APICaller.shared.getPopular { result in
                switch result {
                case .success(let title):
                    
                    cell.configure(with: title)
                    
                case .failure(let error):
                    print(error)
                }
            }
        case Sections.Upcoming.rawValue:
            APICaller.shared.getUpcomingMovies(page: page) { result in
                switch result {
                case .success(let title):
                    cell.configure(with: title)
                case .failure(let error):
                    print(error)
                }
            }
        case Sections.TopRated.rawValue:
            APICaller.shared.getTopRated { result in
                switch result {
                case .success(let title):
                    cell.configure(with: title)
                case .failure(let error):
                    print(error)
                }
            }
        default:
            return UITableViewCell()
        }
        
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else {return}
        
        header.textLabel?.font = .systemFont(ofSize: 18,weight: .semibold)
        header.textLabel?.frame = CGRect(x: header.bounds.origin.x + 20, y: header.bounds.origin.y, width: 100, height: header.bounds.height)
        header.textLabel?.textColor = .white
        header.textLabel?.text = header.textLabel?.text?.capitalizeFirstLetter()
    }
    
    
    
}


extension HomeViewController{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) { // navigation barı yukardaki simgielerin oldugu seyi yukarı yapıştırıyor ve aşagı inince ful ekran yapıyo bu algoritma
        
        let defaultOffset = view.safeAreaInsets.top
        let offset = scrollView.contentOffset.y + defaultOffset
        
        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0, -offset))
        
        
    }
}


extension HomeViewController:CollectionViewTableViewCellDelegate{
    func collectionViewTableViewCellDidTapCell(_ cell: CollectionViewTableViewCell, viewModel: TitleDetailViewModel) {
        DispatchQueue.main.async { [weak self] in
            let vc = TitleDetailViewController()
            
            vc.configure(with: viewModel)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
       
    }
    
    
}
