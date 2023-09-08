//
//  MyCollectionVC.swift
//  WhaleBox
//
//  Created by 刘思源 on 2023/9/8.
//

import UIKit
import EmptyDataSet_Swift

class MyCollectionVC: BaseVC {
    
    var tableView: UITableView!
    
    var posts = [PostModel](){
        didSet{
            tableView.reloadData()
        }
    }

    override func configSubViews() {
        self.title = "帖子收藏"
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
