//
//  DevicesViewController.swift
//  CombineDevicePowerUsageCalculator
//
//  Created by Kacper Trębacz on 23/03/2022.
//

import UIKit
import Combine

enum Section {
    case first
}

class DevicesViewController: UIViewController, Coordinating {
    var coordinator: Coordinator?
    var subscriptions = Set<AnyCancellable>()

    let devicesVM = DevicesViewModel()

    @IBOutlet weak var devicesTableView: UITableView!
    var dataSource: UITableViewDiffableDataSource<Section, DeviceModel>?

    override func viewDidLoad() {
        super.viewDidLoad()
        basicSetup()
    }

    func basicSetup() {
        devicesVM.performBindings()
        setupNavBar()
        setupTableView()
        updateDataSource()
        performBindings()
    }

    func performBindings() {
        devicesVM.$devices
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateDataSource()
            }.store(in: &subscriptions)
    }

    func setupNavBar() {
        title = "Your Devices"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addBarButtonClicked))
    }

    @objc func addBarButtonClicked() {
        coordinator?.eventOccured(with: .goToAddDevices)
    }
}

extension DevicesViewController: UITableViewDelegate {
    func setupTableView() {
        devicesTableView.delegate = self
        devicesTableView.register(UINib(nibName: "DevicesTableViewCell", bundle: nil),
                                  forCellReuseIdentifier: "DevicesCell")
        dataSource = UITableViewDiffableDataSource(tableView: devicesTableView,
                                                   cellProvider: { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: "DevicesCell",
                                                     for: indexPath) as? DevicesTableViewCell
            cell?.setupCell(device: itemIdentifier)
            return cell
        })

    }

    func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, DeviceModel>()
        snapshot.appendSections([.first])
        snapshot.appendItems(devicesVM.devices)
        dataSource?.apply(snapshot)
    }
}
