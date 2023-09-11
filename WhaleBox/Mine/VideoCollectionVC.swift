//
//  VideoCollectionVC.swift
//  WhaleBox
//
//  Created by 刘思源 on 2023/9/11.
//

import UIKit

class VideoCell: UICollectionViewCell {
    
    var cover : UIImageView!
    var titleLabel: UILabel!
    var authorAvatar : UIImageView!
    var authorNameLabel : UILabel!
    
    var videoModel: GKDYVideoModel?{
        didSet{
            guard let videoModel = videoModel else {return}
            
            titleLabel.text = videoModel.title
            cover.kf.setImage(with: URL(string: videoModel.poster_big))
            authorAvatar.kf.setImage(with: URL(string: videoModel.author_avatar))
            authorNameLabel.text = videoModel.source_name
            
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubviews()
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configSubviews(){
        cover = .init()
        contentView.addSubview(cover)
        cover.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel = .init()
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.right.equalTo(-12)
            //make.bottom.equalTo(-8)
        }
        titleLabel.chain.backgroundColor(.kBlack.alpha(0.3)).text(color: .white).font(.systemFont(ofSize: 14)).numberOfLines(2)
        
        authorAvatar = .init()
        contentView.addSubview(authorAvatar)
        authorAvatar.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.bottom.equalTo(-8)
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.width.height.equalTo(30)
        }
        authorAvatar.chain.corner(radius: 15).clipsToBounds(true)
        
        authorNameLabel = .init()
        contentView.addSubview(authorNameLabel)
        authorNameLabel.snp.makeConstraints { make in
            make.left.equalTo(authorAvatar.snp.right).offset(8)
            make.centerY.equalTo(authorAvatar)
        }
        authorNameLabel.chain.backgroundColor(.kBlack.alpha(0.3)).text(color: .kLightGray).font(.systemFont(ofSize: 12))
    
    }
}

class VideoCollectionVC: BaseVC {
    var collectionView: UICollectionView!
    let disposeBag = DisposeBag()
    
    var videosRelay = BehaviorRelay(value: [GKDYVideoModel]())
    
    
    override func configSubViews() {
        
        let layout = UICollectionViewFlowLayout()
        let inset = 16.0
        let spacing = 16.0
        
        let itemW = (kScreenWidth - inset * 2 - spacing) * 2
        let itewH = itemW * 1.333
        layout.itemSize = CGSizeMake(itemW, itewH)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: "cellId")
        videosRelay.bind(to: collectionView.rx.items(cellIdentifier: "cellId", cellType: VideoCell.self)) {index , element, cell in
            cell.videoModel = element
        }.disposed(by: disposeBag)
        
        collectionView.rx.itemSelected.subscribe {[weak self] indexPath in
            guard let self = self else {return}
            let vc = GKDYPlayerViewController()
            vc.prepare(self.videosRelay.value, at: indexPath.row)
            self.navigationController?.pushViewController(vc, animated: true)
            
        }.disposed(by: disposeBag)
    }
    
    
    override func networkRequest() {
        userService.request(.collectVideoList) {[weak self] result in
            guard let self = self else {return}
            result.hj_map2( GKDYVideoModel.self) { body, error in
                if let error = error {
                    error.msg.hint()
                    return
                }
                self.videosRelay.accept(body!.decodedObjList!)
            }
        }
    }
    
    
    
}
