//
//  ViewController.swift
//  SnapKitDemo
//
//  Created by ZHANGLIANG on 2018/10/7.
//  Copyright © 2018 zhangliang. All rights reserved.
//

import UIKit
import SnapKit
import CocoaChainKit

class ViewController: UIViewController {
    var bottomConstraints:Constraint?
    var tooBar = UIView()

    var sendBtn = UIButton(type: .system).chain.title("发送", for: .normal).titleColor(.white, for: .normal).backgroundColor(.orange).addTarget(self, action: #selector(sendMessage(sender:)), for: .touchUpInside).cornerRadius(5).build

    var textField = UITextField().chain.borderStyle(TextFieldBorderStyle.roundedRect).build

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "键盘"

        tooBar.backgroundColor =  UIColor(red: 207/255, green: 211/255, blue: 216/255, alpha: 1)
        self.view.addSubview(tooBar)


        //添加按钮约束
        tooBar.addSubview(sendBtn)

        sendBtn.snp.makeConstraints { (make) in
            make.width.equalTo(60)
            make.height.equalTo(30)
            make.top.equalTo(tooBar).offset(10)
            make.right.equalTo(tooBar).offset(-10)
        }

        //添加输入
        tooBar.addSubview(textField)
        //添加约束
        textField.snp.makeConstraints { (make) in
            make.left.equalTo(tooBar).offset(10)
            make.right.equalTo(sendBtn.snp.left).offset(-10)
            make.height.equalTo(30)
            make.top.equalTo(tooBar).offset(10)
        }

        //监听键盘通知  键盘即将弹出
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)  ), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        let tapSingle = UITapGestureRecognizer(target: self, action: #selector(tapsingleDid))
        tapSingle.numberOfTapsRequired = 1
        tapSingle.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(tapSingle)
    }

    @objc func tapsingleDid(){
        //点击事件
        print("点击")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        textField.resignFirstResponder()
    }

    //MAR: - 键盘即将出现
    @objc func keyboardWillChange(notification:Notification){
        weak var weakSelf = self //弱引用
        let kbInfo = notification.userInfo
        //获取键盘的size
        let kbRect = (kbInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        //键盘弹出时间
        let duration = kbInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        //设置动画曲线
        let curve = kbInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        self.tooBar.snp.updateConstraints { (make) in
            make.height.equalTo(50)
        }
        //改变下约束
        self.bottomConstraints?.update(offset: -kbRect.height)
        if duration != nil{
            UIView.animate(withDuration: duration!, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve!), animations: {

                weakSelf?.view.layoutIfNeeded()
                weakSelf?.view.layoutSubviews()
            }, completion: nil)
        }
    }

    //MARK: - 键盘即将消失
    @objc func keyboardWillHide(notification:Notification){
         weak var weakSelf = self //弱引用
        let kbInfo = notification.userInfo
        //获取键盘的size
        //let kbRect = (kbInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        //键盘弹出时间
        let duration = kbInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        //设置曲线
        let curve = kbInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        self.tooBar.snp.updateConstraints { (make) in
            if #available(iOS 11.0, *){
                make.height.equalTo(50 + self.view.safeAreaInsets.bottom)
            }else{
                make.height.equalTo(50)
            }
        }
        //改变下约束
        self.bottomConstraints?.update(offset: 0)
        if duration != nil{
            UIView.animate(withDuration: duration!, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve!), animations: {
                weakSelf?.view.layoutIfNeeded()
                weakSelf?.view.layoutSubviews()
            }, completion: nil)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        print(self.view.safeAreaInsets)
    }

    override func viewSafeAreaInsetsDidChange() {
        print(self.view.safeAreaInsets)

        //设置底部工具栏视图约束
        self.tooBar.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            if #available(iOS 11.0, *){
                make.height.equalTo(50 + self.view.safeAreaInsets.bottom)
                self.bottomConstraints = make.bottom.equalTo(self.view).constraint
            }else{
                make.height.equalTo(50)
                self.bottomConstraints = make.bottom.equalTo(self.view).constraint
            }
        }
    }

    //发送按钮点击
    @objc func sendMessage(sender:AnyObject){
        //关闭键盘
        //MARK: - 键盘即将回收
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
           textField.resignFirstResponder()
        print("文本内容为：",self.textField.text ?? "文本为空")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

