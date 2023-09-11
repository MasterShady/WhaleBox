//
//  CircleCatVC.swift
//  WhaleBox
//
//  Created by 刘思源 on 2023/9/11.
//

import UIKit



class CatCell: UITableViewCell {
    var data: (title:String, icon:String)? {
        didSet{
            if let data = data{
                titleLabel.text = data.title
                iconView.image = .init(named: data.icon)
            }
        }
    }
    var iconView: UIImageView!
    var titleLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .white
        configSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configSubViews(){
        iconView = UIImageView()
        contentView.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.top.equalTo(14)
            make.left.equalTo(20)
            make.bottom.equalTo(-14)
            make.width.height.equalTo(50)
        }
        iconView.chain.corner(radius: 6).clipsToBounds(true)
        
        titleLabel = UILabel()
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(20)
            make.centerY.equalToSuperview()
            
        }
        titleLabel.chain.font(.semibold(16)).text(color: .kTextBlack)
    }

}

class CircleCatVC: BaseVC {
    
    let disposedBag = DisposeBag()
    
    var didSelectedCat : StringBlock?
    
    let datasouce = [
        ("无畏契约", "无畏契约"),
        ("永劫无间", "永劫无间"),
        ("PC游戏", "PC"),
        ("博德之门", "博德之门"),
    ]

    override func configNavigationBar() {
        self.title = "圈子"
    }
    
    override func configSubViews() {
        view.backgroundColor = .white
        let tableView = UITableView()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.register(CatCell.self, forCellReuseIdentifier: "cellId")
        tableView.separatorStyle = .none
        
        
        
        BehaviorRelay(value: datasouce).bind(to: tableView.rx.items(cellIdentifier: "cellId", cellType: CatCell.self)) { row, data, cell in
            cell.data = data
        }.disposed(by: disposedBag)
        
        tableView.rx.itemSelected.subscribe {[weak self] indexPath in
            guard let self = self else {return}
            let data = self.datasouce[indexPath.row]
            if self.didSelectedCat == nil{
                let vc = PostListVC(cat: data.0)
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                self.didSelectedCat?(data.0)
            }
            
            
        }.disposed(by: disposedBag)
        
        tableView.tableFooterView = {
            let view = UIView()
            view.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 50)
            
            let title = UILabel()
            view.addSubview(title)
            title.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalTo(20)
            }
            title.text = "更多游戏,敬请期待 ~"
            title.font = .systemFont(ofSize: 14)
            title.textColor = .kTextLightGray
            
            return view
        }()
    }
    
    
    


}
