//
//  CustomSegment.swift
//  DevRevAssignment
//
//  Created by Jatin Menghani on 11/02/24.
//

import UIKit

protocol DRVSegmentedControlDelegate: AnyObject {
    func segmentDidChange(to index: Int)
}

class DRVSegmentedControl: UIView {
    
    private var buttonTitles: [String] = ["Now playing", "Popular"]
    private var buttons: [UIButton] = []
    private var selectorView: UIView!
    private var unselectedView: UIView!
    
    var textColor: UIColor = .lightGray
    var selectorViewColor: UIColor = .black
    var selectorTextColor: UIColor = .black
    
    weak var delegate: DRVSegmentedControlDelegate?
    
    private(set) var selectedIndex: Int = 0
    
    convenience init(frame: CGRect, buttonTitles: [String]) {
        self.init(frame: frame)
        self.buttonTitles = buttonTitles
        setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .white
        createButtons()
        configureStackView()
        configSelectorView()
    }
    
    func setButtonTitles(buttonTitles: [String]) {
        self.buttonTitles = buttonTitles
        setupView()
    }
    
    func setIndex(index: Int) {
        buttons.forEach { $0.setTitleColor(textColor, for: .normal) }
        let button = buttons[index]
        selectedIndex = index
        button.setTitleColor(selectorTextColor, for: .normal)
    }
    
    @objc private func buttonAction(sender: UIButton) {
        guard let buttonIndex = buttons.firstIndex(of: sender) else { return }
        
        buttons.forEach { $0.setTitleColor(textColor, for: .normal) }
        sender.setTitleColor(selectorTextColor, for: .normal)
        delegate?.segmentDidChange(to: buttonIndex)
        
        let button = buttons[buttonIndex]
        UIView.animate(withDuration: 0.3) {
            self.selectorView.frame.origin.x = button.frame.origin.x
            self.selectorView.frame.size.width = button.frame.size.width
        }
        
        selectedIndex = buttonIndex
    }
    
    private func createButtons() {
        buttons = [UIButton]()
        buttons.removeAll()
        subviews.forEach { $0.removeFromSuperview() }
        
        for (index, buttonTitle) in buttonTitles.enumerated() {
            let button = UIButton(type: .system)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            button.setTitle(buttonTitle, for: .normal)
            button.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
            button.setTitleColor(textColor, for: .normal)
            button.contentHorizontalAlignment = .left
            button.tag = index
            buttons.append(button)
        }
        
        buttons[0].setTitleColor(selectorTextColor, for: .normal)
    }
    
    private func configureStackView() {
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .horizontal
        stack.alignment = .leading
        stack.distribution = .fillProportionally
        stack.spacing = 20
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func configSelectorView() {
        let unselectedWidth = frame.width
        unselectedView = UIView(frame: CGRect(x: 0, y: self.frame.height, width: unselectedWidth, height: 2))
        addSubview(unselectedView)
                
        let initialSelectorFrame = CGRect(x: 0, y: self.frame.height, width: (frame.width / CGFloat(self.buttonTitles.count)) - 120, height: 2)
        selectorView = UIView(frame: initialSelectorFrame)
        selectorView.backgroundColor = selectorViewColor
        addSubview(selectorView)
    }
}
