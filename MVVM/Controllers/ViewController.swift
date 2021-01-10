//
//  ViewController.swift
//  MVVM
//
//  Created by Ahmed on 1/10/21.
//

import UIKit

//MARK: - Models
enum Gender {
    case male, female
}

struct Person {
    let name: String
    let gender: Gender
    let isBeenFollowed: Bool
    let height: Double
    
    init(
        name: String,
        gender: Gender,
        height: Double
    ) {
        self.name =  name
        self.gender = Gender.male
        self.isBeenFollowed = false
        self.height = height
    }
}

//MARK: - ViewModels

struct PersonViewModel {
    let name: String
    var isBeenFollowed: Bool
    
    init(with model: Person) {
        self.name =  model.name
        self.isBeenFollowed = model.isBeenFollowed
    }
}

//MARK: - Cell Delegate

protocol UserTableViewCellDelegate: AnyObject {
    func userTableViewCell(_ cell: UserTableViewCell, didTapWith model: PersonViewModel)
}

//MARK: - Cell Controller

class UserTableViewCell: UITableViewCell {
    
    public static let identifier = "UserTableViewCell"
    public weak var delegate: UserTableViewCellDelegate?
    
    private var modelView: PersonViewModel?
    
    private let userName: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    private let followButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.clipsToBounds = true
        button.layer.cornerRadius = 5
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        [userName, followButton ].forEach { contentView.addSubview($0) }
        accessoryType = .none
        
        followButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
    }
    
    @objc private func didTapButton(_ sender: UIButton){
        guard let viewModel = self.modelView else {
            return
        }
        var newViewModel = viewModel
        newViewModel.isBeenFollowed = !viewModel.isBeenFollowed
        
        delegate?.userTableViewCell(self, didTapWith: newViewModel)
        prepareForReuse()
        configure(with: newViewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userName.frame = CGRect(
            x: 10,
            y: 5,
            width: 150,
            height: 30
        )
        
        followButton.frame = CGRect(
            x: contentView.frame.width - 110 - 10,
            y: (contentView.frame.height - 35) / 2,
            width: 110,
            height: 35
        )
               
    }

    
    public func configure(with model: PersonViewModel) {
        self.modelView = model
        
        userName.text = model.name
        
        if model.isBeenFollowed {
            followButton.setTitle("Unfollow", for: .normal)
            followButton.backgroundColor = .white
            followButton.setTitleColor(.link, for: .normal)
            followButton.titleEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
            followButton.layer.borderWidth = 1
            followButton.layer.borderColor = UIColor.link.cgColor
        } else {
            followButton.setTitle("Follow", for: .normal)
            followButton.backgroundColor = .link
            followButton.setTitleColor(.white, for: .normal)
            followButton.titleEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userName.text = nil
        followButton.setTitle(nil, for: .normal)
        followButton.backgroundColor = nil
        followButton.layer.borderWidth = 0
        followButton.setTitleColor(nil, for: .normal)
    }
}

//MARK: - View Controllers

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UserTableViewCell.self,
                       forCellReuseIdentifier: UserTableViewCell.identifier)
        return table
    }()
    
    private var users = [Person]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        configure()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func configure() {
        for index in 1...20 {
            let isEven = index % 2 == 0
            let newUser = Person(
                name: "user \(index)",
                gender: isEven ? .male : .female,
                height: 2.3
            )
            users.append(newUser)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: UserTableViewCell.identifier,
            for: indexPath
        ) as! UserTableViewCell
        let user = users[indexPath.row]
        cell.configure(with: PersonViewModel(with: user))
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ViewController : UserTableViewCellDelegate {
    
    func userTableViewCell(_ cell: UserTableViewCell, didTapWith model: PersonViewModel) {
        
    }
}
