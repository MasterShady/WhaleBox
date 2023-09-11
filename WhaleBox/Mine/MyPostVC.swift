//
//  MyPostVC.swift
//  WhaleBox
//
//  Created by 刘思源 on 2023/9/8.
//

import UIKit
import EmptyDataSet_Swift


class MyPostVC: BaseVC {

    
    var tableView: UITableView!
    
    var posts = [PostModel](){
        didSet{
            tableView.reloadData()
        }
    }

    override func configSubViews() {
        self.title = "我的帖子"
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
        userService.request(.postList(type: 1)) {[weak self] result in
            result.hj_map2(PostModel.self) { body, error in
                if let error = error{
                    error.msg.hint()
                    return
                }
                self?.posts = body!.decodedObjList!
            }
        }
    }


}

extension MyPostVC : UITableViewDelegate, UITableViewDataSource, EmptyDataSetSource{
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
        return .init("暂时没有发帖哦~", color: .kTextLightGray, font: .systemFont(ofSize: 14))
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = AEAlertView(style: .defaulted, title: "删除帖子", message: "删除后数据不可恢复,确定删除吗?")
            alert.addAction(action: .init(title: "确定", handler: {[weak alert, weak self] action in
                guard let self = self else {return}
                let post = self.posts.remove(at: indexPath.row)
                tableView.reloadData()
                userService.request(.deletePost(id: post.id)) { result in
                    result.hj_map2 { body, error in
                        if let error = error{
                            error.msg.hint()
                            return
                        }
                        "删除成功".hint()
                        //NotificationCenter.post(name: .localFileLoadCompleted)
                    }
                    
                }
                alert?.dismiss()
            }))
            
            alert.addAction(action: .init(title: "再想想", handler: {[weak alert] action in
                alert?.dismiss()
            }))
            alert.show()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
