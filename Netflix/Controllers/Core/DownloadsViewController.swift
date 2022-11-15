//
//  DownloadsViewController.swift
//  Netflix
//
//  Created by Ios Developer on 7.11.2022.
//

import UIKit

class DownloadsViewController: UIViewController {

    
    private var titles:[TitleItem] = [TitleItem]() // titles veritabındakileri almalı
    
    private let downloadedTable:UITableView = {
        let table = UITableView()
        table.register(UpcomingTableViewCell.self, forCellReuseIdentifier: UpcomingTableViewCell.identifier)
        return table
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Downloads"
        view.addSubview(downloadedTable)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        downloadedTable.delegate = self
        downloadedTable.dataSource = self
        
        fetchLocalStorageForDownload()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("downloaded"), object: nil, queue: nil) { _ in
            self.fetchLocalStorageForDownload()
        }
        
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        downloadedTable.frame = view.bounds
    }
    
    //override func viewWillAppear(_ animated: Bool) { //notification yapmasaydım böyle yapabilirdim
    //    fetchLocalStorageForDownload()
   // }
    
    

    
    //veritabanında title leri getircek ve sonucu titles e eşitlicek
    private func fetchLocalStorageForDownload(){
        DataPersistenceManeger.shared.fetchingTitlesFromDataBase { [weak self] result in
            DispatchQueue.main.async {
                switch result{
                case .success(let titles):
                    self?.titles = titles
                    self?.downloadedTable.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
           
        }
    }
   

}

extension DownloadsViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UpcomingTableViewCell.identifier, for: indexPath) as? UpcomingTableViewCell else {return UITableViewCell()}
        
        let title = titles[indexPath.row]
        cell.configure(with: TitleViewModel(titleName: title.original_name ?? title.original_title ?? "unknown", posterURL: title.poster_path ?? ""))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle{
        case .delete:
            DataPersistenceManeger.shared.deleteTitleWith(model: titles[indexPath.row]) { [weak self] result in
                switch result{
                case .success():
                    print("deleted from the database")
                case .failure(let error):
                    print(error.localizedDescription)
                }
                self?.titles.remove(at: indexPath.row) // titles dizisinden de kaldırmalıyız (önce diziden kaldır sonra açagıdaki gibi tableviewden yoksa hata verir)
                tableView.deleteRows(at: [indexPath], with: .fade) // table viewden kaldırıyoruz .fade solma efektiyle kaldırır
                
            }
        default:
            break;
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let title = titles[indexPath.row]
        guard let titleName = title.original_title ?? title.original_name else{return}
        
        APICaller.shared.getMovie(with: titleName + "trailer") { [weak self] result in
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
