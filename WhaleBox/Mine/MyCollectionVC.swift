//
//  MyCollectionVC.swift
//  WhaleBox
//
//  Created by 刘思源 on 2023/9/8.
//

import UIKit
import EmptyDataSet_Swift
import JXSegmentedView

class MyCollectionVC: BaseVC {
    
    var tableView: UITableView!
    
    var posts = [PostModel](){
        didSet{
            tableView.reloadData()
        }
    }

    override func configSubViews() {
        self.title = "我的收藏"
        tableView = UITableView()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(PostCell.self)
        tableView.emptyDataSetSource = self
        
    }
    

    override func networkRequest() {
        userService.request(.collectList) {[weak self] result in
            result.hj_map2(PostModel.self) { body, error in
                if let error = error{
                    error.msg.hint()
                    return
                }
                self?.posts = body!.decodedObjList!
                for post in self!.posts{
                    post.is_collect = true
                }
            }
        }
    }
}

extension MyCollectionVC : UITableViewDelegate, UITableViewDataSource, EmptyDataSetSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(PostCell.self)
        cell.post = self.posts[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = PostDetailVC(post: self.posts[indexPath.row])
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return .init(named: "no_data")?.byResize(to: CGSize(width: 100, height: 100))
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return .init("暂时没有收藏哦~", color: .kTextLightGray, font: .systemFont(ofSize: 14))
    }
}

extension MyCollectionVC :JXSegmentedListContainerViewListDelegate{
    func listView() -> UIView {
        return self.view
    }
}


class CollectionPageVC: BaseVC {
    var page = 0
    override func configSubViews() {
        self.navigationItem.titleView = segmentedV
        view.addSubview(listContainerView)
        segmentedDS.titles = ["帖子","视频"]
        segmentedV.dataSource = segmentedDS
        segmentedV.listContainer = listContainerView
        segmentedV.defaultSelectedIndex = page
        segmentedV.reloadData()
    }
    
    
    lazy var listContainerView: JXSegmentedListContainerView = {
        let lv = JXSegmentedListContainerView(dataSource: self)
        lv.frame = CGRect(x: 0, y: kNavBarMaxY, width: kScreenWidth, height: kScreenHeight - kNavBarMaxY)
        return lv
    }()
    private lazy var segmentedV: JXSegmentedView = {
        let segment = JXSegmentedView(frame:CGRect(x: 0, y: 0, width: 150, height: 35))
        segment.backgroundColor = .clear
        segment.indicators = [sliderView]
        return segment
    }()
    private lazy var segmentedDS: JXSegmentedTitleDataSource = {
        let source = JXSegmentedTitleDataSource()
        source.titleNormalFont = .systemFont(ofSize: 15)
        source.titleNormalColor = .kTextLightGray
        source.titleSelectedFont = .semibold(18)
        source.titleSelectedColor = .kTextBlack
        return source
    }()
    
    lazy var sliderView: JXSegmentedIndicatorLineView = {
        let view = JXSegmentedIndicatorLineView()
        view.indicatorColor = .kBlack
        view.indicatorWidth = 14 //横线宽度
        view.indicatorHeight = 3 //横线高度
        view.verticalOffset = 0 //垂直方向偏移
        view.indicatorCornerRadius = 2
        return view
    }()
    
    
}

extension CollectionPageVC: JXSegmentedListContainerViewDataSource {
    //MARK: JXSegmentedViewDelegate
    //点击标题 或者左右滑动都会走这个代理方法
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        //这里处理左右滑动或者点击标题的事件
        
    }
    //MARK:JXSegmentedListContainerViewDataSource
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        2
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        if index == 0 {
            let vc = MyCollectionVC()
            return vc
        }
        else {
            let vc = VideoCollectionVC()
            return vc
        }
        
    }
    
}
