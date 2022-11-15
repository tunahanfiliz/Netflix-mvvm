//
//  HeroHeaderUIView.swift
//  Netflix
//
//  Created by Ios Developer on 7.11.2022.
//

import UIKit

class HeroHeaderUIView: UIView {

    private let heroImageView:UIImageView = {
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill //dolgu veriyo
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "g")
        
        return imageView
    }()
    
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.setTitle("Play", for: .normal)
        button.layer.borderColor = UIColor.white.cgColor //sınır çerçevesinin rengi
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        
        return button
    }()
    
    private let downloadButton: UIButton = {
        let button = UIButton()
        button.setTitle("Download", for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        
        return button
    }()
    
    /*public let headerLabel :UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 32,weight: .bold)
        label.text = "testsadas dasdasdasd2321 "
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()*/
    
    
    private func addGradient(){ // baş postere gorunum ayarı
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.systemBackground.cgColor
        ]
        gradientLayer.frame = bounds
        layer.addSublayer(gradientLayer) //alt görünüm
    }
    
    private func applyConstraints(){
        
        NSLayoutConstraint.activate([
        
            playButton.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 70),
            playButton.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -50),
            playButton.widthAnchor.constraint(equalToConstant: 120)
        
        ])
        
        NSLayoutConstraint.activate([
            downloadButton.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -70),
            downloadButton.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -50),
            downloadButton.widthAnchor.constraint(equalToConstant: 120)
        
        ])
        
       
    }
    
    public func configure(with model:TitleViewModel){
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500/\(model.posterURL)")  else {return}
        heroImageView.sd_setImage(with: url)
        
        
    }

    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(heroImageView)
        addGradient()
        addSubview(downloadButton)
        addSubview(playButton)
        
        applyConstraints()
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        heroImageView.frame = bounds
        
        
    }
    
    

}
