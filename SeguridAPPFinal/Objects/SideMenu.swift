//
//  SideMenu.swift
//  SeguridAPPFinal
//
//  Created by Marcos Amaury Rodríguez Ruiz on 13/04/21.
//

import Foundation
import UIKit
protocol MenuControllerDelegate{
    func didSelectMenuItem(named:String)
}

class MenuController: UITableViewController {
    
    public var delegate: MenuControllerDelegate?
    
    private let menuItems: [String]
    
    init(with menuItems: [String]){
        self.menuItems = menuItems
        super.init(nibName: nil, bundle: nil)
        //tableView.register(UITableView.self, forCellReuseIdentifier: "cell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return menuItems.count
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = menuItems[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedItem = menuItems[indexPath.row]
        delegate?.didSelectMenuItem(named: selectedItem)
    }
}
