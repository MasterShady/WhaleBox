//
//  HomeVC.swift
//  WhaleBox
//
//  Created by 刘思源 on 2023/9/4.
//

import UIKit
import JXSegmentedView
import JXPagingView

extension JXPagingListContainerView: JXSegmentedViewListContainer {}

class HomeVC: BaseVC {
    
//    lazy var headerView: UIView = {
//        let image = UIImage(named: "header_bg")!
//        let headerView = UIImageView(image: image)
//        headerView.clipsToBounds = true
//        headerView.contentMode = .scaleAspectFill
//        headerView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: image.size.height/image.size.height * kScreenWidth)
//        return headerView
//    }()
    
    var stackView: UIStackView!
    var segmentView: JXSegmentedView!
    
    var strategies = [News]()
    var news = [News]()
    
    
    var pagingView: JXPagingView!
    var userHeaderView: PagingViewTableHeaderView!
    var userHeaderContainerView: UIView!
    var segmentedViewDataSource: JXSegmentedTitleDataSource!
    var segmentedView: JXSegmentedView!
    let titles = ["攻略", "新闻"]
    var JXTableHeaderViewHeight = 280.rw
    var JXheightForHeaderInSection = 48.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navBarBgAlpha = 0
        userHeaderContainerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: JXTableHeaderViewHeight))
        userHeaderView = PagingViewTableHeaderView(frame: userHeaderContainerView.bounds)
        userHeaderView.clickBannerHandler = { [weak self] in
            guard let self = self else {return}
            let news = self.strategies.first { news in
                news.id == 176
            }
            self.navigationController?.pushViewController(NewsDetailVC(news: news!), animated: true)
        }
        userHeaderContainerView.addSubview(userHeaderView)
        
        //segmentedViewDataSource一定要通过属性强持有！！！！！！！！！
        segmentedViewDataSource = JXSegmentedTitleDataSource()
        segmentedViewDataSource.titles = titles
        segmentedViewDataSource.titleSelectedColor = .kTextBlack
        segmentedViewDataSource.titleSelectedFont = .semibold(18)
        segmentedViewDataSource.titleNormalColor = .kTextDrakGray
        segmentedViewDataSource.titleNormalFont = .systemFont(ofSize: 18)
        segmentedViewDataSource.isTitleColorGradientEnabled = true
        segmentedViewDataSource.isTitleZoomEnabled = true
        
        segmentedView = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: JXheightForHeaderInSection))
        segmentedView.backgroundColor = UIColor.white
        segmentedView.dataSource = segmentedViewDataSource
        segmentedView.isContentScrollViewClickTransitionAnimationEnabled = false
        
        let lineView = JXSegmentedIndicatorLineView()
        lineView.indicatorColor = .kThemeColor
        lineView.indicatorWidth = 28
        lineView.indicatorHeight = 4
        segmentedView.indicators = [lineView]
        
//        let lineWidth = 1/UIScreen.main.scale
//        let lineLayer = CALayer()
//        lineLayer.backgroundColor = UIColor.lightGray.cgColor
//        lineLayer.frame = CGRect(x: 0, y: segmentedView.bounds.height - lineWidth, width: segmentedView.bounds.width, height: lineWidth)
//        segmentedView.layer.addSublayer(lineLayer)
        
        pagingView = JXPagingView(delegate: self)
        
        self.view.addSubview(pagingView)
        
        segmentedView.listContainer = pagingView.listContainerView
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pagingView.frame = self.view.bounds
    }
    
    override func networkRequest() {
        userService.request(.getNewsList(1)) {[weak self] result in
            guard let self = self else {return}
            result.hj_map2(News.self) { body, error in
                if let error = error{
                    error.msg.hint()
                    return
                }
                self.strategies = body!.decodedObjList!
                self.pagingView.reloadData()
            }
        }
        
        userService.request(.getNewsList(0)) {[weak self] result in
            result.hj_map2(News.self) { body, error in
                if let error = error{
                    error.msg.hint()
                    return
                }
                self?.news = body!.decodedObjList!
                self?.pagingView.reloadData()
            }
        }
    }
}

extension HomeVC: JXPagingViewDelegate {
    
    func tableHeaderViewHeight(in pagingView: JXPagingView) -> Int {
        return Int(JXTableHeaderViewHeight)
    }
    
    func tableHeaderView(in pagingView: JXPagingView) -> UIView {
        return userHeaderContainerView
    }
    
    func heightForPinSectionHeader(in pagingView: JXPagingView) -> Int {
        return Int(JXheightForHeaderInSection)
    }
    
    func viewForPinSectionHeader(in pagingView: JXPagingView) -> UIView {
        return segmentedView
    }
    
    func numberOfLists(in pagingView: JXPagingView) -> Int {
        return titles.count
    }
    
    func pagingView(_ pagingView: JXPagingView, initListAtIndex index: Int) -> JXPagingViewListViewDelegate {
        let list = PagingListBaseView()
        if index == 0 {
            list.dataSource = strategies
        }else if index == 1 {
            list.dataSource = news
        }
        list.beginFirstRefresh()
        return list
    }
    
    func mainTableViewDidScroll(_ scrollView: UIScrollView) {
        userHeaderView?.scrollViewDidScroll(contentOffsetY: scrollView.contentOffset.y)
    }
}
