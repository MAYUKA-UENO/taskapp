import RealmSwift

class Task: Object
{
    //管理用IDプライマリーキー
    @objc dynamic var id = 0
    
    //タイトル
    @objc dynamic var title = ""

    //カテゴリー
    @objc dynamic var category = ""

    //内容
    @objc dynamic var contents = ""

    //日時
    @objc dynamic var date = Date()

    //idをプライマリーキーとして設定
    override static func primaryKey() -> String?
    {
        return "id"
    }
}
