//
//  ItemTableViewCell.swift
//  Todoey
//
//  Created by Yerzhan Syzdyk on 01.03.2023.
//

import UIKit

final class DataTableViewCell: UITableViewCell {
    
    static let IDENTIFIER = "itemTableViewCell"
    
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
    
    func configure(with text: String){
        nameLabel.text = text
    }

}


//MARK: setup views and constraints

extension DataTableViewCell{
    func setupViews(){
        contentView.addSubview(nameLabel)
    }
    func setupConstraints(){
        nameLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
    }
}
