import UIKit

// MVC
// Model-View-Controller


// UIViewController
class FirstViewController: UIViewController {
    
    private let customView = View()
    private let model = FirstService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // запрос данных из View (триггерится при вызове requestData)
        customView.action = { [weak self] in
            // запрос данных в model
            self?.model.getDataFromNetwork { data in
                // получение сырых данных из Model/Service и дальнейший парсинг внутри VC
                guard let data = self?.parseDataFromNetwork(data) else { return }
                self?.customView.setupData(data)
            }
        }
        
        // вызываем запрос данных из View
        customView.requestData()
    }
    
    // Данного метода здесь быть не должно, логика парсинга выносится в отдельный объект
    private func parseDataFromNetwork(_ data: Data) -> String {
        // Просходит некоторая логика
        let result = "Готовая распарсенная строка из данных сети типа Data"
        return result
    }
    
}

// UIView
class View {
    
    var action: (() -> Void)?
    
    private var data: String!
    
    func requestData() {
        print("Нужны данные из сети, дай мне их")
        action?()
    }
    
    func setupData(_ data: String) {
        self.data = data
        print("Получили данные из сети и показали их пользователю: \(data)")
    }
    
}

// Model
// Обычно тут может творится хаос из доп. сервисов внутри и View Controller'у необходимо будет выполнять доп. логику по стыковке данных из этих сервисов из-за чего тело VC расширяется
class FirstService {
    
    func getDataFromNetwork(_ completion: ((Data) -> Void)?) {
        // Просходит некоторое ожидание ответа от сервера с URLSession и далее выполняется логика ниже
        print("Отправляю сырые данные из сети, получатель их получит в функции completion")
        let data = Data()
        completion?(data)
    }
    
}


// MVP
// Model-View-Presenter


// UIViewController
class SecondViewController: UIViewController {
    
    private let customView = View()
    private let presenter = Presenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // запрос из данных view
        customView.action = { [weak self] in
            self?.presenter.getData()
        }
        
        customView.requestData()
    }
    
    // получение данных из Presenter
    func sendData(_ data: String) {
        customView.setupData(data)
    }
    
}

// Presenter
class Presenter {
    
    weak var viewController: SecondViewController?
    
    private let networkManager = NetworkManager()
    
    init() {
        networkManager.result = { [weak self] in
            self?.parseData($0)
        }
    }
    
    func getData() {
        // Просходит запрос данных из сети через networkManager
        networkManager.getDataFromNetwork()
    }
    
    private func parseData(_ data: Data) {
        // Просходит некоторая логика парсинга, возможно даже через JSONDecoder
        let result = "Готовая распарсенная строка из данных сети"
        viewController?.sendData(result)
    }
    
}

// NetworkManager
class NetworkManager {
    
    var result: ((Data) -> Void)?
    
    func getDataFromNetwork() {
        // Просходит запрос данных из сети через URLSession
        // URLSession.dataTask()...
        print("Отправляю сырые данные из сети в виде Data в метод result")
        let data = Data()
        result?(data)
    }
    
}


// MVVM
// Model-View-ViewModel


// UIViewController
class FirdViewController: UIViewController {
    
    private let customView = View()
    private let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // запрос из данных view
        customView.action = { [weak self] in
            self?.viewModel.getData()
        }
        // получаем данные из VM
        viewModel.resultAction = { [weak self] data in
            self?.customView.setupData(data)
        }
        
        customView.requestData()
    }
    
}

// ViewModel
class ViewModel {
    
    var resultAction: ((String) -> Void)?
    
    private let networkManager = NetworkManager()
    
    init() {
        networkManager.result = { [weak self] in
            self?.parseData($0)
        }
    }
    
    func getData() {
        // Просходит запрос данных из сети через networkManager
        networkManager.getDataFromNetwork()
    }
    
    private func parseData(_ data: Data) {
        // Просходит некоторая логика парсинга, возможно даже через JSONDecoder
        let string = "Готовая распарсенная строка из данных сети"
        resultAction?(string)
    }
    
}


// VIPER
// View-Interactor-Presenter-Entity-Router


// UIViewController
class FouthViewController: UIViewController {
    
    private let customView = View()
    private let presenter = FouthPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // запрос из данных view
        customView.action = { [weak self] in
            // запрос данных через презентер из сети
            self?.presenter.getDatagetDataFromNetwork()
        }
        
        customView.requestData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // запрос данных через презентер из локальной базы данных
        presenter.getDatagetDataFromDataBase()
    }
    
    // получение данных из Presenter
    func sendData(_ data: String) {
        customView.setupData(data)
    }
    
}

// FouthPresenter
class FouthPresenter {
    
    weak var viewController: FouthViewController?
    
    private let interactor = Interactor()
    
    init() {
        interactor.resultAction = { [weak self] in
            self?.parseData($0)
        }
    }
    
    func getDatagetDataFromNetwork() {
        // Просходит запрос данных из сети через interactor
        interactor.getDataFromNetwork()
    }
    
    func getDatagetDataFromDataBase() {
        // Просходит запрос данных из локальной базы данных через interactor
        interactor.getDataFromNetwork()
    }
    
    private func parseData(_ data: Data) {
        // Просходит некоторая логика парсинга, возможно даже через JSONDecoder
        let string = "Готовая распарсенная строка из данных сети"
        viewController?.sendData(string)
    }
    
}

// Interactor
class Interactor {
    
    var resultAction: ((Data) -> Void)?
    
    private let networkManager = NetworkManager()
    private let dataBase = DataBase()
    
    init() {
        networkManager.result = { [weak self] in
            self?.resultAction?($0)
        }
        
        dataBase.result = { [weak self] in
            self?.resultAction?($0)
        }
    }
    
    func getDataFromNetwork() {
        // Просходит запрос данных из сети через networkManager
        networkManager.getDataFromNetwork()
    }
    
    func getDataFromDataBase() {
        // Просходит запрос данных из локальной базы данных
        networkManager.getDataFromNetwork()
    }
    
}

// DataBase -> локальная база данных
class DataBase {
    
    var result: ((Data) -> Void)?
    
    func getData() {
        let data = Data()
        result?(data)
    }
    
}

