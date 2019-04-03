import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate,  UISearchBarDelegate, UITableViewDataSource  {

    var searchResult = [String]()

    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchbar: UISearchBar!
    

    
   var taskcategory = try! Realm().objects(Task.self).filter("category IN {%@, %@, %@, %@, %@}", "study", "work", "excersize", "hobby", "code")

    // Realmインスタンスを取得する
    let realm = try! Realm()  // ←追加
   var searchFlag: Bool = false
    // DB内のタスクが格納されるリスト。
    // 日付近い順\順でソート：降順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)  // ←追加

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchbar.delegate = self

        }
    
    


  func searchBarTextDidEndEditing(_ searchbar: UISearchBar) {
        searchFlag = true
        if let search = searchbar.text{
            taskcategory = try! Realm().objects(Task.self).filter("taskcategory = '\(search)'")
        } else {
            taskcategory = try! Realm().objects(Task.self).filter("category IN {%@, %@, %@, %@, %@}","study", "work", "excersize", "hobby", "code")
        }
        tableView.reloadData()
    }
 



    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if searchbar.text != "" {
     return taskcategory.count
        } else {
        
        return taskArray.count
        }
     
    }
    

    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       

        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
         if searchFlag == true {
            let task = taskcategory[indexPath.row]
            cell.textLabel?.text = "\(task.title) \(task.category)"
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            let dateString:String = formatter.string(from: task.date)
            cell.detailTextLabel?.text = dateString
            


        } else {
            
            let task = taskArray[indexPath.row]
            cell.textLabel?.text = "\(task.title) \(task.category)"
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            let dateString:String = formatter.string(from: task.date)
            cell.detailTextLabel?.text = dateString
            
        }

        return cell
    }
    
            
    
    

    
    



  

    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "CellSegue",sender: nil)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // --- ここから ---
        if editingStyle == .delete {
            // 削除するタスクを取得する
            let task = self.taskArray[indexPath.row]

            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
                
            }
        } // --- ここまで変更 ---
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    // segue で画面遷移するに呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        if segue.identifier == "CellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
           
        } else {
            let task = Task()
            task.date = Date()
            
     
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
            
        }
    }
    // 検索ボタンが押された時に呼ばれる
    func searchBarSearchButtonClicked(_ searchbar: UISearchBar) {
        self.view.endEditing(true)
        searchbar.showsCancelButton = true


        self.tableView.reloadData()
    }
    
    // キャンセルボタンが押された時に呼ばれる
    func searchBarCancelButtonClicked(_ searchbar: UISearchBar) {
        searchbar.showsCancelButton = false
        self.view.endEditing(true)
        searchbar.text = ""
        self.tableView.reloadData()
    }
    
    // テキストフィールド入力開始前に呼ばれる
    func searchBarShouldBeginEditing(_ searchbar: UISearchBar) -> Bool {
        searchbar.showsCancelButton = true
        return true
    }

}

    








 
    

    

    



