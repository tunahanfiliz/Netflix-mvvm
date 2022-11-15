//
//  CollectionViewTableViewCell.swift
//  Netflix
//
//  Created by Ios Developer on 7.11.2022.
//

import UIKit



protocol CollectionViewTableViewCellDelegate:AnyObject{
    func collectionViewTableViewCellDidTapCell(_ cell:CollectionViewTableViewCell, viewModel: TitleDetailViewModel) //tıklandıktan sonrası için . bunu aşagıda didselectte kullaancaz
}




class CollectionViewTableViewCell: UITableViewCell {
    
    static let identifier = "CollectionViewTableViewCell"
    
    
    weak var delegate:CollectionViewTableViewCellDelegate?
    
    
    public var titles:[Title] = [Title]() // başlıkları tutmak için
    
    
    private let collectionView:UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 140, height: 200)
        
        
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TitleCollectionViewCell.self, forCellWithReuseIdentifier: TitleCollectionViewCell.identifier)
        
        
        return collectionView
        
    }()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .red
        contentView.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.bounds
    }
    
    
    func configure(with titles:[Title]){  // gelen başlıkları beslemek için .. Homeview de cellrowat in içinde çagırcazz
        self.titles = titles
        
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    
    //veritabanına indirme
    private func downloadTitleAt(indexPath: IndexPath){
       // print("downloading \(titles[indexPath.row].original_title ?? "")")
        
        // bu işlemle beraber title miz veritabanının içinde
        DataPersistenceManeger.shared.downloadTitleWith(model: titles[indexPath.row]) { result in
            switch result{
            case .success():
                print("dowladed to database")
                NotificationCenter.default.post(name: NSNotification.Name("downloaded"), object: nil)
            case .failure(let error):
                print(error.localizedDescription )
            }
        }
        
    }
    
    
    
 
}
 
extension CollectionViewTableViewCell:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionViewCell.identifier, for: indexPath) as? TitleCollectionViewCell else {return UICollectionViewCell() }
        guard let model = titles[indexPath.row].poster_path else {return UICollectionViewCell()}
        cell.configure(with: model) //başlıkları çekmek için
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true) // ögenin seçimini kaldırır
        
        let title = titles[indexPath.row]
        guard let titleName = title.original_title ?? title.original_name else {return}
        
        APICaller.shared.getMovie(with: titleName + "trailer") { [weak self] result in // içerde kullancagımız için ve asenkron . atıfta bulunmak için self
            switch result{
            case .success(let videoElement):
                
                let title = self?.titles[indexPath.row]
                guard let titleOverview = title?.overview else {return}
                guard let strongSelf = self else{return}
                let viewModel = TitleDetailViewModel(title: titleName, youtubeView: videoElement, titleOverview: titleOverview)

                self?.delegate?.collectionViewTableViewCellDidTapCell(strongSelf, viewModel:viewModel )
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        // bu işlem basılı tutup download seçenegini çıkarıyo
        
            let config = UIContextMenuConfiguration(
                identifier: nil,
                previewProvider: nil) {[weak self] _ in
                    let downloadAction = UIAction(title: "Download", subtitle: nil, image: nil, identifier: nil, discoverabilityTitle: nil, state: .off) { _ in
                        self?.downloadTitleAt(indexPath: indexPath)
                        
                    }
                    return UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [downloadAction]) //children içi dizi olacak ve indirme islemleri içinde olcak
                }
            
            return config
        }
}
