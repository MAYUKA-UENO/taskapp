
import UIKit
import RealmSwift
import UserNotifications

//【追加】検索（サーチバーデリゲート）
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate
{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var CategorySearch: UISearchBar!//【追加】検索

    //Realmインスタンスをrealmに代入する
    let realm = try! Realm()

    //【追加】22行目でwordが使われていないと言われたので、wordをString型として定義してみた部分。
    //var word :String = ""

    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)//taskArrayはreamlを絞り込んだもの、これをTableViewに表示させている。
            
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.fillerRowHeight = UITableView.automaticDimension//データを表示していない部分に罫線を表示する
        tableView.delegate = self
        tableView.dataSource = self
        CategorySearch.delegate = self//【追加】検索
    }
    
    //画面遷移するときに呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue"
        {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        }
        else
        {
            let task = Task()
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0
            {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task

            
        }
    }

    //入力画面から戻ってきたときにTableViewを更新させる
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    //データの数を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)-> Int
    {
        return taskArray.count
        //return categoryArray.count//【追加】カテゴリー
    }
    
    //各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)//再利用可能なcellを得る
        
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        
        return cell
    }

    //各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }

    //各セルが削除が可能なことを伝えるメソッド(削除可能かどうか、並び替えが可能かどうかなど、編集ができるかを返す部分)
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
    {
        return .delete
    }

    //Deleteボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            //削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            //let category = self.categoryArray[indexPath.row]//【追加】カテゴリー
            
            //ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            //データベースから削除する
            try! realm.write
            {
                self.realm.delete(self.taskArray[indexPath.row])
                //self.realm.delete(self.categoryArray[indexPath.row])//【追加】カテゴリー
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            //未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests
            {
                (requests: [UNNotificationRequest])in
                for request in requests
                {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)//【追加】検索
    {
        view.endEditing(true)//キーボードを閉じる
        if let word = searchBar.text, searchBar.text != ""
        {
            print(word)
            taskArray = try! Realm().objects(Task.self).filter("category = '\(word)'")//【追加】カテゴリー
            print("該当するデータの数は\(taskArray.count)")
            tableView.reloadData()
        }
        else
        {
            //taskArray = try! Realm().objects(Task.self).filter("TRUEPREDICATE")//TRUEPREDICATEを使ってもOK
            taskArray = try! Realm().objects(Task.self)
            print(taskArray)
            print("すべてのデータの数は\(taskArray.count)")
            tableView.reloadData()
        }
    }
    
}

