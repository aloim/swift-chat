//
//  BrowserCollectionController.swift
//  Ubiquity
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class BrowserListController: UICollectionViewController {
    
    internal init(container: Container) {
        self.container = container
        super.init(collectionViewLayout: BrowserListLayout())
    }
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func loadView() {
        super.loadView()
        // setup controller
        title = "Collection"
        
        // setup colleciton view
        collectionView?.register(BrowserListCell.dynamic(with: UIImageView.self), forCellWithReuseIdentifier: "ASSET-IMAGE")
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
    }
    
    internal let container: Container
}

///
/// Provide collection view display support
///
extension BrowserListController: UICollectionViewDelegateFlowLayout {
    
    internal override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return container.numberOfSections
    }
    internal override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return container.numberOfItems(inSection: section)
    }
    
    internal override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "ASSET-IMAGE", for: indexPath)
    }
    internal override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell =  cell as? BrowserListCell else {
            return
        }
        return cell.apply(for: container.item(at: indexPath))
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }
        return layout.itemSize
    }
    
    internal override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        logger.trace(indexPath)
        
        let controller = BrowserDetailController(container: container, at: indexPath)
        let animator = Animator(destination: controller, source: self, at: indexPath)
            //BrowserAnimator(destination: controller, source: self, at: indexPath)
        
        controller.animator = animator
        controller.transitioningDelegate = animator
        
        show(controller, sender: indexPath)
    }
}

///
/// Provide animatable transitioning support
///
extension BrowserListController: AnimatableTransitioningDelegate {
    
    // generate transition object for key and index path
    internal func transitioningScene(using animator: Animator, operation: TransitioningOperation, at indexPath: IndexPath) -> TransitioningScene? {
        let scene = TransitioningScene()
        scene.contentMode = .scaleAspectFill
        scene.contentOrientation = .up
        return scene
    }
    // prepare transition animation
    internal func animationPreparing(using animator: Animator, context: TransitioningContext) {
        logger.debug("\(collectionView!.contentInset)")
        // must be attached to the collection view
        guard let collectionView = collectionView, let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout  else {
            return
        }
        // check the index path is displaying
        if !collectionView.indexPathsForVisibleItems.contains(context.indexPath) {
            // no, scroll to the cell at index path
            collectionView.scrollToItem(at: context.indexPath, at: .centeredVertically, animated: false)
            // must call the layoutIfNeeded method, otherwise cell may not create
            collectionView.layoutIfNeeded()
        }
        // fetch cell at index path, if is displayed
        guard let cell = collectionView.cellForItem(at: context.indexPath) as? BrowserListCell else {
            return
        }
        let source = context.scene(for: .source)
        source.view = cell
        // if it is to, reset cell boundary
        guard context.operation == .pop || context.operation == .dismiss else {
            return
        }
        let edg = collectionView.contentInset
        let frame = cell.convert(cell.bounds, to: view)
        let height = view.frame.height - topLayoutGuide.length - bottomLayoutGuide.length
      
        let y1 = -edg.top + frame.minY
        let y2 = -edg.top + frame.maxY
        
        // reset content offset if needed
        if y2 > height {
            // bottom over boundary, reset to y2(bottom)
            collectionView.contentOffset.y += y2 - height
        } else if y1 < 0 {
            // top over boundary, rest to y1(top)
            collectionView.contentOffset.y += y1
        }

    }
//    internal func animateTransition(using animator: Animator, context: TransitioningContext) {
//        context.completeTransition(true)
//    }
}
//
//    func showDetail(at indexPath: IndexPath, animated: Bool) {
//        let controller = BrowseDetailViewController()
//        
//        controller.delegate = delegate
//        controller.dataSource = dataSource
//        
//        _browseAnimator = IBControllerAnimator(from: self, to: controller)
//        _browseIndexPath = indexPath
//        
//        // self => controller
//        
//        let root = view.window?.rootViewController
//        
//        if let nav = root as? UINavigationController {
//            nav.delegate = _browseAnimator
//            nav.pushViewController(controller, animated: true)
//        } else {
//            controller.transitioningDelegate = _browseAnimator
//            root?.present(controller, animated: true, completion: nil)
//        }
//    }
//    
//    func showDetail(_ asset: Browseable, animated: Bool) {
//        let controller = BrowseDetailViewController()
//        
//        controller.view.backgroundColor = asset.backgroundColor
//        
//        show(controller, sender: self)
//    }
