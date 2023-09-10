//
//  SearchVC.swift
//  WhaleBox
//
//  Created by 刘思源 on 2023/9/11.
//

import Foundation
import RxCocoa
import Moya


class SearchVC :BaseVC{
    
    let disposeBag = DisposeBag()
    
    var allData = [News]()
    var resultData = BehaviorRelay(value: [News]())
    
    var tableView: UITableView!
    var searchTf: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        searchTf.becomeFirstResponder()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func configSubViews() {
        self.edgesForExtendedLayout = .all
        let fakeNavBar = UIView()
        view.addSubview(fakeNavBar)
        
        
        
        fakeNavBar.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
            make.height.equalTo(kNavBarMaxY)
        }
        fakeNavBar.backgroundColor = .white
        let barContainer = UIView()
        fakeNavBar.addSubview(barContainer)
        barContainer.snp.makeConstraints { make in
            make.top.equalTo(kStatusBarHeight)
            make.left.right.equalToSuperview()
            make.height.equalTo(kNavBarHeight)
        }
        
        let backButton = UIButton()
        barContainer.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.width.height.equalTo(24)
            make.centerY.equalToSuperview()
        }
        backButton.chain.normalImage(.init(named: "nav_back"))
        
        backButton.addBlock(for: .touchUpInside) {[weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        searchTf = UITextField()
        barContainer.addSubview(searchTf)
        searchTf.snp.makeConstraints { make in
            make.left.equalTo(backButton.snp.right).offset(8)
            make.right.equalTo(-16)
            make.height.equalTo(32)
            make.centerY.equalToSuperview()
        }
        searchTf.chain.backgroundColor(.kExLightGray).corner(radius: 16).clipsToBounds(true)
        searchTf.attributedPlaceholder = .init("请输入关键词 ~", color: .kTextLightGray, font: .systemFont(ofSize: 14))
        
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 32))
        let searchIcon = UIImageView(frame: CGRect(x: 10, y: 8, width: 16, height: 16))
        leftView.addSubview(searchIcon)
        searchIcon.image = .init(named: "search_icon")
        
        searchTf.leftView = leftView
        searchTf.leftViewMode = .always
        
        
        tableView = UITableView()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(fakeNavBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        tableView.chain.backgroundColor(.white).separatorStyle(.none)
        tableView.register(NewsCell.self, forCellReuseIdentifier: "cellId")
        
        let nodataView = UIView()
        view.addSubview(nodataView)
        nodataView.snp.makeConstraints { make in
            make.top.equalTo(fakeNavBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        let nodataImageView = UIImageView()
        nodataView.addSubview(nodataImageView)
        nodataImageView.image = .init(named: "no_data")
        nodataImageView.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(nodataView.snp.centerY)
        }
        
        let nodataLabel = UILabel()
        nodataView.addSubview(nodataLabel)
        nodataLabel.snp.makeConstraints { make in
            make.top.equalTo(nodataImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        nodataLabel.chain.text(color: .kTextLightGray).text("没有搜索到相关新闻/攻略哦\n换个关键词吧~").font(.systemFont(ofSize: 14)).numberOfLines(0).textAlignment(.center)
        
        
        searchTf.rx.text.orEmpty
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged().subscribe {[weak self] value in
                guard let self = self else {return}
                        let news = self.allData.filter {
                            $0.title!.contains(value) || $0.detail_content.contains(value)
                        }
                self.resultData.accept(news)
            }.disposed(by: disposeBag)
        
        
        self.resultData.map {[weak self] data in
            guard let self = self else { return true }
            return data.count > 0 || (self.searchTf.text!.count == 0)
            
        }.bind(to:nodataView.rx.isHidden).disposed(by: disposeBag)
        
        _ = resultData.take(until: rx.deallocated).bind(to: tableView.rx.items(cellIdentifier: "cellId", cellType: NewsCell.self)) { row, element ,cell in
            cell.model = element
        }
        
        _ = tableView.rx.itemSelected.take(until: rx.deallocated).subscribe { [weak self] indexPath in
            guard let self = self else { return }
            let news = self.resultData.value[indexPath.row]
            UIViewController.getCurrentNav().pushViewController(NewsDetailVC(news: news), animated: true)
        }
        
    }
    
    override func networkRequest() {
        userService.request(.getNewsList(0)) { result in
            result.hj_map2(News.self) { body, error in
                if let body = body{
                    self.allData.append(contentsOf: body.decodedObjList!)
                }
            }
            
        }
        
        userService.request(.getNewsList(1)) { result in
            result.hj_map2(News.self) { body, error in
                if let body = body{
                    self.allData.append(contentsOf: body.decodedObjList!)
                }
            }
        }
    }
    
    
    
}
