//
//  UpcomingTableViewCell.swift
//  Netflix
//
//  Created by Ios Developer on 9.11.2022.
//

import UIKit

protocol UpcomingTableViewCellDelegate{
    func buttonClickedDidTap(indexPath:IndexPath)
}



class UpcomingTableViewCell: UITableViewCell {

    static let identifier = "UpcomingTableViewCell"
    
    var delegate:UpcomingTableViewCellDelegate?
    var indexPath:IndexPath?
    
    private let playTitleButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        
        let image = UIImage(systemName: "play.circle",withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
        button.setImage(image, for: .normal)
        
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        
        return button
    }()
    
    @objc func buttonClicked(sender: UIButton!){
        delegate?.buttonClickedDidTap(indexPath: indexPath!)
    }
    
    
    private let titleLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 18)
        
        
        return label
        
    }()
    
    private let titlesPosterImageView:UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true // taşmasın
        
        
        return imageView
    }()
    
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titlesPosterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(playTitleButton)
        
        applyConstraints()
        
        
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
   
    
    
    private func applyConstraints(){
        NSLayoutConstraint.activate([
            titlesPosterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titlesPosterImageView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 5),
            titlesPosterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -5),
            titlesPosterImageView.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: titlesPosterImageView.trailingAnchor,constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 200)
        
        ])
        
        NSLayoutConstraint.activate([
            playTitleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -20),
            playTitleButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    public func configure(with model: TitleViewModel){
        
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500/\(model.posterURL)")  else {return}
        titlesPosterImageView.sd_setImage(with: url)
        titleLabel.text = model.titleName
    }
    
    
    
}
