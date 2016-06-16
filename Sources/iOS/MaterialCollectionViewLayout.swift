/*
* Copyright (C) 2015 - 2016, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.io>.
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*
*	*	Redistributions of source code must retain the above copyright notice, this
*		list of conditions and the following disclaimer.
*
*	*	Redistributions in binary form must reproduce the above copyright notice,
*		this list of conditions and the following disclaimer in the documentation
*		and/or other materials provided with the distribution.
*
*	*	Neither the name of Material nor the names of its
*		contributors may be used to endorse or promote products derived from
*		this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
* AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
* IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
* FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
* DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
* CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
* OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
* OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import UIKit

public class MaterialCollectionViewLayout : UICollectionViewLayout {
	/// Used to calculate the dimensions of the cells.
	internal var offset: CGPoint = CGPoint.zero
	
	/// The size of items.
	public var itemSize: CGSize = CGSize.zero
	
	/// A preset wrapper around contentInset.
	public var contentInsetPreset: MaterialEdgeInset = .none {
		didSet {
			contentInset = MaterialEdgeInsetToValue(contentInsetPreset)
		}
	}
	
	/// A wrapper around grid.contentInset.
	public var contentInset: UIEdgeInsets = UIEdgeInsetsZero
	
	/// Size of the content.
	public private(set) var contentSize: CGSize = CGSize.zero
	
	/// Layout attribute items.
	public private(set) var layoutItems: Array<(UICollectionViewLayoutAttributes, IndexPath)> = Array<(UICollectionViewLayoutAttributes, IndexPath)>()
	
	/// Cell data source items.
	public private(set) var dataSourceItems: Array<MaterialDataSourceItem>?
	
	/// Scroll direction.
	public var scrollDirection: UICollectionViewScrollDirection = .vertical
	
	/// A preset wrapper around spacing.
	public var spacingPreset: MaterialSpacing = .none {
		didSet {
			spacing = MaterialSpacingToValue(spacingPreset)
		}
	}
	
	/// Spacing between items.
	public var spacing: CGFloat = 0
	
	/**
	Retrieves the index paths for the items within the passed in CGRect.
	- Parameter rect: A CGRect that acts as the bounds to find the items within.
	- Returns: An Array of NSIndexPath objects.
	*/
	public func indexPathsOfItemsInRect(_ rect: CGRect) -> Array<IndexPath> {
		var paths: Array<IndexPath> = Array<IndexPath>()
		for (attribute, indexPath) in layoutItems {
			if rect.intersects(attribute.frame) {
				paths.append(indexPath)
			}
		}
		return paths
	}
	
	public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		let attributes: UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
		let item: MaterialDataSourceItem = dataSourceItems![(indexPath as NSIndexPath).item]
		
		if 0 < itemSize.width && 0 < itemSize.height {
			attributes.frame = CGRect(x: offset.x, y: offset.y, width: itemSize.width - contentInset.left - contentInset.right, height: itemSize.height - contentInset.top - contentInset.bottom)
		} else if .vertical == scrollDirection {
			attributes.frame = CGRect(x: contentInset.left, y: offset.y, width: collectionView!.bounds.width - contentInset.left - contentInset.right, height: nil == item.height ? collectionView!.bounds.height : item.height!)
		} else {
			attributes.frame = CGRect(x: offset.x, y: contentInset.top, width: nil == item.width ? collectionView!.bounds.width : item.width!, height: collectionView!.bounds.height - contentInset.top - contentInset.bottom)
		}
		
		return attributes
	}
	
	public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		var layoutAttributes: Array<UICollectionViewLayoutAttributes> = Array<UICollectionViewLayoutAttributes>()
		for (attribute, _) in layoutItems {
			if rect.intersects(attribute.frame) {
				layoutAttributes.append(attribute)
			}
		}
		return layoutAttributes
	}
	
	public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		return .vertical == scrollDirection ? newBounds.width != collectionView!.bounds.width : newBounds.height != collectionView!.bounds.height
	}
	
	public override func collectionViewContentSize() -> CGSize {
		return contentSize
	}
	
	public override func prepare() {
		if let dataSource: MaterialCollectionViewDataSource = collectionView?.dataSource as? MaterialCollectionViewDataSource {
			prepareLayoutForItems(dataSource.items())
		}
	}
	
	public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
		return proposedContentOffset
	}
	
	private func prepareLayoutForItems(_ dataSourceItems: Array<MaterialDataSourceItem>) {
		self.dataSourceItems = dataSourceItems
		layoutItems.removeAll()
		
		offset.x = contentInset.left
		offset.y = contentInset.top
		
		var indexPath: IndexPath?
		
		for i in 0..<dataSourceItems.count {
			let item: MaterialDataSourceItem = dataSourceItems[i]
			indexPath = IndexPath(item: i, section: 0)
			layoutItems.append((layoutAttributesForItem(at: indexPath!)!, indexPath!))
			
			offset.x += spacing
			offset.x += nil == item.width ? itemSize.width : item.width!
			
			offset.y += spacing
			offset.y += nil == item.height ? itemSize.height : item.height!
		}
		
		offset.x += contentInset.right - spacing
		offset.y += contentInset.bottom - spacing
		
		if 0 < itemSize.width && 0 < itemSize.height {
			contentSize = CGSize(width: offset.x, height: offset.y)
		} else if .vertical == scrollDirection {
			contentSize = CGSize(width: collectionView!.bounds.width, height: offset.y)
		} else {
			contentSize = CGSize(width: offset.x, height: collectionView!.bounds.height)
		}
	}
}
