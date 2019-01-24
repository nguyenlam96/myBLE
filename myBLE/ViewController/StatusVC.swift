//
//  StatusVC.swift
//  myBLE
//
//  Created by Nguyen Lam on 1/22/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit
import CoreBluetooth

class StatusVC: UIViewController {

    // MARK: - Properties:
    var servicesDict: [String:CBService] = [:]
    var characteristicDict: [String:CBCharacteristic] = [:]
    
    var servicesList:  [ [String:CBService] ] = [ [:] ]
    var characteristicsList:  [ [String:CBCharacteristic] ] = [ [:] ]
    
    // MARK: - IBOutlet:
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deviceNameLabel: UILabel!
    
    // MARK: - ViewLifeCycle:
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        BLEManager.shared.delegate = self
        
    }
    
    func getListOfServiceAndChar() {
        for (key,value) in servicesDict {
            servicesList.append([key : value])
        }
        
        for (key, value) in characteristicDict {
            characteristicsList.append([key : value])
        }
    }
    
}

extension StatusVC: BLEManagerDelegate {

    func handleServicesAndCharacteristicsReceved(serviesDict: [String : CBService], charDict: [String : CBCharacteristic]) {
        LogUtils.LogTrace(type: .startFunc)
        self.servicesDict = serviesDict
        self.characteristicDict = charDict
        self.getListOfServiceAndChar()
        tableView.reloadData()
        LogUtils.LogTrace(type: .endFunc)
    }
}

extension StatusVC: UITableViewDelegate, UITableViewDataSource {
    // MARK: - TableView Datasource:
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return servicesList.count
        } else {
            return characteristicsList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statusCell", for: indexPath)
        if indexPath.section == 0 {
            let service = servicesList[indexPath.row]
            cell.textLabel?.text = "\(service.keys)"
            cell.detailTextLabel?.text = "\(service.values)"
        } else {
            let char = characteristicsList[indexPath.row]
            cell.textLabel?.text = "\(char.keys)"
            cell.detailTextLabel?.text = "\(char.values)"
        }
        return cell
    }
    
    // MARK: - TableView Delegate:
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}

