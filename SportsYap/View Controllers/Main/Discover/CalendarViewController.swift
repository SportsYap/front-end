//
//  CalendarViewController.swift
//  SportsYap
//
//  Created by Master on 2020/3/28.
//  Copyright © 2020 Alex Pelletier. All rights reserved.
//

import UIKit
import JTAppleCalendar

protocol CalendarViewControllerDelegate {
    func didSelectDate(date: Date)
}

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var calendarView: JTACMonthView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var prevMonthButton: UIButton!
    @IBOutlet weak var nextMonthButton: UIButton!
    
    var selectedDate: Date?
    var delegate: CalendarViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        calendarView.visibleDates {[unowned self] (visibleDates: DateSegmentInfo) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
        if let date = selectedDate {
            calendarView.selectDates([date], triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: false)
            calendarView.scrollToDate(date)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CalendarViewController {
    
    @IBAction func onPrevMonth(_ sender: Any) {
        calendarView.scrollToSegment(.previous, triggerScrollToDateDelegate: true, animateScroll: true)
    }
    
    @IBAction func onNextMonth(_ sender: Any) {
        calendarView.scrollToSegment(.next, triggerScrollToDateDelegate: true, animateScroll: true)
    }
}

extension CalendarViewController {
    private func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        guard let startDate = visibleDates.monthDates.first?.date else {
            return
        }
        
        let calendar = Calendar.current
        let month = calendar.dateComponents([.month], from: startDate).month!
        let monthName = DateFormatter().monthSymbols[(month - 1) % 12]
        // 0 indexed array
        let year = calendar.component(.year, from: startDate)
        monthLabel.text = monthName + " " + String(year)
    }
    
    private func handleCellConfiguration(cell: JTACDayCell?, cellState: CellState) {
        handleCellSelection(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }

    private func handleCellTextColor(view: JTACDayCell?, cellState: CellState) {
        guard let myCustomCell = view as? CalendarDayCell  else {
            return
        }
        
        if cellState.isSelected {
            myCustomCell.dayLabel.textColor = .white
        } else if cellState.date.isToday {
            myCustomCell.dayLabel.textColor = UIColor(hex: "FF4F56")
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                myCustomCell.dayLabel.textColor = UIColor(hex: "009BFF")
            } else {
                myCustomCell.dayLabel.textColor = .gray
            }
        }
    }

    private func handleCellSelection(view: JTACDayCell?, cellState: CellState) {
        guard let myCustomCell = view as? CalendarDayCell else {return }
        
        if cellState.isSelected {
            myCustomCell.selectedView.backgroundColor =  .black
        } else {
            myCustomCell.selectedView.backgroundColor = .clear
        }
    }
}

extension CalendarViewController: JTACMonthViewDelegate, JTACMonthViewDataSource {
    
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        let year = Date().year
        
        let startDate = formatter.date(from: "\(year - 1) 01 01")!
        let endDate = formatter.date(from: "\(year + 1) 12 01")!
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)

        return parameters
    }
    
    func configureVisibleCell(myCustomCell: CalendarDayCell, cellState: CellState, date: Date, indexPath: IndexPath) {
        myCustomCell.dayLabel.text = cellState.text
        handleCellConfiguration(cell: myCustomCell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        // This function should have the same code as the cellForItemAt function
        let myCustomCell = cell as! CalendarDayCell
        configureVisibleCell(myCustomCell: myCustomCell, cellState: cellState, date: date, indexPath: indexPath)
    }
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let myCustomCell = calendar.dequeueReusableCell(withReuseIdentifier: "dayCell", for: indexPath) as! CalendarDayCell
        configureVisibleCell(myCustomCell: myCustomCell, cellState: cellState, date: date, indexPath: indexPath)
        return myCustomCell
    }

    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        handleCellConfiguration(cell: cell, cellState: cellState)
    }

    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        handleCellConfiguration(cell: cell, cellState: cellState)
        delegate?.didSelectDate(date: date)
    }
    
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
}
