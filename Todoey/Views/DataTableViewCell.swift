//
//  ItemTableViewCell.swift
//  Todoey
//
//  Created by Yerzhan Syzdyk on 01.03.2023.
//

import UIKit
import CoreData

final class DataTableViewCell: UITableViewCell, UINavigationControllerDelegate {
    
    static let IDENTIFIER = "itemTableViewCell"
    
    private lazy var myImageView : UIImageView = {
        let myImageView = UIImageView()
        myImageView.image = UIImage(systemName: "camera")
        return myImageView
    }()
    
    private lazy var nameLabel : UILabel = {
        let myLabel = UILabel()
        myLabel.text = "Section"
        myLabel.font = UIFont.systemFont(ofSize: 25)
        return myLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func imageTapped(){
        print("Did pressed!")
    }
    
    func configure(with text: String, tintColor: UIColor,data: Data?){
        nameLabel.text = text
        nameLabel.textColor = tintColor
        
        if let data{
            myImageView.image = UIImage(data: data)
        }else{
            myImageView.image = UIImage(systemName: "camera")
        }
    }

}
//MARK: setup views and constraints

extension DataTableViewCell{
    func setupViews(){
        contentView.addSubview(nameLabel)
        contentView.addSubview(myImageView)
    }
    
    func setupConstraints(){
        nameLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
        myImageView.snp.makeConstraints { make in
            make.top.trailing.bottom.equalToSuperview().inset(3)
            make.width.equalToSuperview().multipliedBy(0.2)
        }
    }
}
