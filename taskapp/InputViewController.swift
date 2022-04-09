
import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryField: UITextField!
    
    let realm = try! Realm()
    var task: Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //背景をタップしたらdismissKeyboardメソッドを呼ぶ
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        categoryField.text = task.category//【追加】カテゴリー
        contentsTextView.text = task.contents
        datePicker.date = task.date
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        try! realm.write
        {
            self.task.title = self.titleTextField.text!
            self.task.category = self.categoryField.text!//【追加】カテゴリー
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.realm.add(self.task, update: .modified)
        }
        setNotification(task: task)
        super.viewWillDisappear(animated)
    }
    
    //タスクのローカル通知を登録する
    func setNotification(task: Task)
    {
        let content = UNMutableNotificationContent()
        //通知のタイトルと内容を設定
        if task.title == ""//タイトルが入力されてなかったら「タイトルなし」と通知する
        {
            content.title = "(タイトルなし)"
        }
        else
        {
            content.title = task.title
        }
        if task.contents == ""//内容が入力されてなかったら「タイトルなし」と通知する
        {
            content.body = "(内容なし)"
        }
        else
        {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default
        //ローカル通知が発動するトリガー（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day,  .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        //identifier, content, triggerからローカル通知を作成
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        
        //ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request)
        {
            (error)in
            print(error ?? "ローカル通知登録OK")//errorがnilならローカル通知の登録に成功したと表示させる
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
    
    @objc func dismissKeyboard()
    {
        //キーボードを閉じる
        view.endEditing(true)
    }
}
