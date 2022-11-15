//
//  UpcomingViewController.swift
//  Netflix
//
//  Created by Ios Developer on 7.11.2022.
//

import UIKit

class UpcomingViewController: UIViewController {

    
    private var titles:[Title] = [Title]()
    private var page : Int = 1
    
    private let upcomingTable:UITableView = {
        
        let table = UITableView()
        table.register(UpcomingTableViewCell.self, forCellReuseIdentifier: UpcomingTableViewCell.identifier)
        return table
    }()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Upcoming"
        navigationController?.navigationBar.prefersLargeTitles = true // yazıyı buyutup solda gösteren bi se
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        view.addSubview(upcomingTable)
        upcomingTable.delegate = self
        upcomingTable.dataSource = self
        
        fetchUpcoming()
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        upcomingTable.frame = view.bounds

        
    }
    
    
    private func fetchUpcoming(){
        APICaller.shared.getUpcomingMovies(page: page) { [weak self] result in
            switch result {
            case .success(let title):
                //self?.titles = title
                self?.titles.append(contentsOf: title)
                self?.page += 1
                DispatchQueue.main.async {
                    self?.upcomingTable.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { // aşagı dogru kaydırdıgımızda durursak scrool degerlerini vericek ve verimli çalışcak. ama sadece scrooldidview fonksiyonunu çagırsaydık her kaydırısta çıkcaktı veri kalabalıgı olcak ve kastırır.
        
        let offsetY = scrollView.contentOffset.y // y ekseninde kaydırıyoruz ya o değerleri verir
        let contentHeight = scrollView.contentSize.height // poster boyutu gibi bi sey
        let height = scrollView.frame.size.height // tüm sayfanın boyutu
        
        print("offsetY:\(offsetY)")
        print("contentHeight:\(contentHeight)")
        print("height:\(height)")
        print("")
        
        if offsetY >= contentHeight - (3 * height){
            fetchUpcoming()
            
            // bu algoritma tüm uzunluktan şeyi çıkardıgımızda yani sayfanın yuzde 85i tamamlandıgında getmovies fonksiyonunu çağır demek. 20tane filmin yuzde 85 ini kaydırarak gördügümüz gibi diger 20 tane diziyi çagırcak ve böyle kaydırdıkça ilerlicek verilere ulascak
        }
       
    }
    
}



extension UpcomingViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UpcomingTableViewCell.identifier, for: indexPath) as? UpcomingTableViewCell else {return UITableViewCell()}
        
        cell.delegate = self
        cell.indexPath = indexPath
        
        let title = titles[indexPath.row]
        cell.configure(with: TitleViewModel(titleName: title.original_name ?? title.original_title ?? "unknown", posterURL: title.poster_path ?? ""))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    
    //TIKLADIKTAN SONRA NE OLSUN ?
    /* func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let title = titles[indexPath.row]
        guard let titleName = title.original_title ?? title.original_name else{return}
        
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
    }*/
    
}

extension UpcomingViewController:UpcomingTableViewCellDelegate{
    func buttonClickedDidTap(indexPath: IndexPath) {
        let title = titles[indexPath.row]
        guard let titleName = title.original_title else{return}
        
        APICaller.shared.getMovie(with:titleName) { [weak self] result in
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
