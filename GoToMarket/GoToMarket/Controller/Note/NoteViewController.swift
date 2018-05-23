//
//  NoteViewController.swift
//  GoToMarket
//
//  Created by 許庭瑋 on 2018/5/23.
//  Copyright © 2018年 許庭瑋. All rights reserved.
//

import UIKit
import CoreData

class NoteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var noteTableView: UITableView!
    
    //MARK: FoldingCell
    private var openedCellIndex: IndexPath?
    private let openedCellHeight: CGFloat = 210.0
    private let closedCellHeight: CGFloat = 110.0
    
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer { didSet { fetchAndReloadData() } }
    var fetchedResultsController: NSFetchedResultsController<UserNotes>?
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noteTableView.delegate = self
        noteTableView.dataSource = self
        noteTableView.estimatedRowHeight = closedCellHeight
        registerCell()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchAndReloadData()
    }

    //MARK: CoreData
    private func fetchAndReloadData() {
        
        if let context = container?.viewContext {
            
            let request: NSFetchRequest<UserNotes> = UserNotes.fetchRequest()
            
            request.sortDescriptors = [NSSortDescriptor(key: "isFinished", ascending: true)]
            
            request.predicate = NSPredicate(format: "(isInCart = true) AND (cropData != nil)")
            
            fetchedResultsController = NSFetchedResultsController<UserNotes>(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            
            fetchedResultsController?.delegate = self
            
            try? fetchedResultsController?.performFetch()
            
            noteTableView.reloadData()
        }
    }

    
    private func registerCell() {
        
        let nibContent = UINib(nibName: "NoteTableViewCell", bundle: nil)
        
        noteTableView.register(
            nibContent,
            forCellReuseIdentifier: String(describing: NoteTableViewCell.self)
        )
    }
    
    //MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            
            let count = sections[section].numberOfObjects
            print("count = \(count)")
            
            return count
            
        } else {
            
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: NoteTableViewCell.self),
            for: indexPath) as! NoteTableViewCell
        
        setupCell(atIndexpath: indexPath, cellBeforeInit: cell)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        print("index.row = \(indexPath.row)")
        
        if indexPath == openedCellIndex {
            
            return openedCellHeight
            
        } else {
            
            return closedCellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = self.noteTableView.cellForRow(at: indexPath) as? NoteTableViewCell else { return }
        
        if cell.isAnimating() {
            
            return
        }
        
        let duration = 0.3
        
        if indexPath == openedCellIndex {
            
            cell.unfold(false, animated: true, completion: nil)
            
            openedCellIndex = nil
            
        } else if openedCellIndex == nil {
            
            cell.unfold(true, animated: true, completion: nil)
            
            openedCellIndex = indexPath
            
        } else {
            
            cell.unfold(true, animated: true, completion: nil)
            
            if
                let openedCell = noteTableView.cellForRow(at: openedCellIndex!) as? NoteTableViewCell,
                let oldOpenedIndex = openedCellIndex {
                
                openedCell.unfold(false, animated: true, completion: nil)
                
                setupCell(atIndexpath: oldOpenedIndex, cellBeforeInit: nil)
            }
            
            openedCellIndex = indexPath
            
        }
        
        setupCell(atIndexpath: indexPath, cellBeforeInit: nil)
            
        UIView.animate(
            withDuration: duration,
            delay: 0,
            animations: {
                
                tableView.beginUpdates()
                tableView.endUpdates()
                
        }, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let showingCell = cell as? NoteTableViewCell else { return }

        if indexPath == openedCellIndex {
            
            showingCell.unfold(true, animated: false, completion: nil)
            
        } else {
            
            showingCell.unfold(false, animated: false, completion: nil)
        }
    }
    
    
    private func setupCell(atIndexpath indexPath: IndexPath, cellBeforeInit newCell: NoteTableViewCell?) {
        
        guard
            let note = fetchedResultsController?.object(at: indexPath),
            let cropData = note.cropData,
            let cell = newCell ?? self.noteTableView.cellForRow(at: indexPath) as? NoteTableViewCell
            else { return }

        if indexPath != openedCellIndex {

            print("row: \(indexPath.row) = close")
            cell.topBuyingAmountLabel.text = String(note.buyingAmount)
            cell.topFinishButton.isSelected = note.isFinished
            //TODO
            cell.topWeightTypeLabel.text = "(每公斤)"
            
            if let cropData = note.cropData {
                
                cell.topCellPriceLabel.text = String(cropData.newAveragePrice * note.customMutipler)
                cell.topItemNameLabel.text = cropData.cropName
            }
            
        } else {
            
            cell.bottomFinishButton.isSelected = note.isFinished
            //TODO
            cell.bottomWeightTypeLabel.text = "(每公斤)"
            cell.bottomBuyingAmountTextField.text = String(note.buyingAmount)

            cell.bottomItemNameLabel.text = cropData.cropName
            cell.bottomSellPriceLabel.text = String(cropData.newAveragePrice * note.customMutipler)
            cell.bottomNewRealPriceLabel.text = String(cropData.newAveragePrice)
            cell.bottomLastRealPriceLabel.text = String(cropData.lastAveragePrice)
            cell.bottomBuyingAmountTextField.delegate = self
        }
    }
    
    //MARK: TextField
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = "0123456789"
        let allowedCharacterSet = CharacterSet(charactersIn: allowedCharacters)
        let typedCharacterSet = CharacterSet(charactersIn: string)
        return allowedCharacterSet.isSuperset(of: typedCharacterSet)
    }
}