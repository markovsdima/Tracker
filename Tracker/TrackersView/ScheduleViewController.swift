//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 20.03.2024.
//

import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func configWeekDays(_: [WeekDay])
}

final class ScheduleViewController: UIViewController {
    
    // MARK: - UI Properties
    private lazy var mainTitle: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(ScheduleTableViewCell.self, forCellReuseIdentifier: "ScheduleTableViewCell")
        //table.backgroundColor = .blue
        table.layer.cornerRadius = 16
        table.allowsSelection = false
        table.isScrollEnabled = false
        table.translatesAutoresizingMaskIntoConstraints = false
        
        return table
    }()
    
    private lazy var finishButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.backgroundColor = .ypBlack
        button.tintColor = .ypWhite
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapFinishButton), for: .touchUpInside)
        
        return button
    }()
    
    private var weekDaysNames = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    
    private var selectedWeekDays = [WeekDay]()
    
    weak var delegate: ScheduleViewControllerDelegate?
    
    
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        tableView.dataSource = self
        tableView.delegate = self
        
        configureUI()
        
            //tableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: "ScheduleTableViewCell")
    }
    
    private func configureUI() {
        view.addSubview(mainTitle)
        view.addSubview(tableView)
        view.addSubview(finishButton)
        
        
        //tableView.backgroundColor = .black
        
        NSLayoutConstraint.activate([
            mainTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 27),
            mainTitle.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: mainTitle.bottomAnchor, constant: 38),
            //tableView.bottomAnchor.constraint(equalTo: finishButton.topAnchor, constant: -39),
            tableView.heightAnchor.constraint(equalToConstant: 524),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            finishButton.heightAnchor.constraint(equalToConstant: 60),
            finishButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            finishButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            finishButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    
    @objc private func didTapFinishButton() {
        delegate?.configWeekDays(selectedWeekDays)
        dismiss(animated: true)
    }
}

// MARK: - Table View Methods
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTableViewCell.reuseIdentifier, for: indexPath)
        guard let cell = cell as? ScheduleTableViewCell else { return UITableViewCell() }
        
        cell.delegate = self
        cell.cellTitle.text = weekDaysNames[indexPath.row]
        //cell.backgroundColor = .ypBlue
        cell.selectionStyle = .none
        cell.backgroundColor = .ypGrayAlpha
        cell.weekDay = WeekDay.allCases[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekDaysNames.count
    }
}

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

extension ScheduleViewController: ScheduleTableViewCellDelegate {
    func switchChanged(for day: WeekDay, enabled: Bool) {
        if enabled == true {
            selectedWeekDays.append(day)
        } else {
            selectedWeekDays.removeAll { $0 == day }
        }
        //print(selectedWeekDays)
    }
    
    
}
