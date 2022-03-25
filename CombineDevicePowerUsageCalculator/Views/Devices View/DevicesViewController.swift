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

    @IBOutlet weak var priceForKwhLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var devicesTableView: UITableView!

    let devicesVM = DevicesViewModel()
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
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                print("update")
                self?.updateDataSource()
            }.store(in: &subscriptions)

        devicesVM.priceForKwh.sink { [weak self] value in
            self?.priceForKwhLabel.text = String(value)
        }.store(in: &subscriptions)

        devicesVM.$totalPrice.sink { [weak self] value in
            self?.totalLabel.text = String(value)
        }.store(in: &subscriptions)

        devicesVM.refreshTableView.sink { _ in
            self.updateDataSource()
        }.store(in: &subscriptions)
    }

    func setupNavBar() {
        title = "Your Devices"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addBarButtonClicked))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: nil,
                                                           image: UIImage(systemName: "gearshape.fill"),
                                                           primaryAction: nil,
                                                           menu: createUIMenu())
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
