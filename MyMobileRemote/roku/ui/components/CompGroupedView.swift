//
//  ComponentGroupedView.swift
//  MyRemote
//
//  Created by Alex DeMeo on 7/23/20.
//  Copyright © 2020 Alex DeMeo. All rights reserved.
//

import SwiftUI

struct ComponentGroupedView: View {
    private let COLS_PER_ROW = 3
    private let views: [AnyView]
    
    init(_ views: [AnyView]) {
        self.views = views
    }
    
    private var groupedViews: [[AnyView]] {
        var result: [[AnyView]] = []
        for i in self.views.indices {
            let view = self.views[i]
            if i % COLS_PER_ROW == 0 {
                result.append([view])
            } else {
                result[result.endIndex - 1].append(view)
            }
        }
        return result
    }
    
    var body: some View {
        let grouped = self.groupedViews
        return VStack {
            ForEach(grouped.indices, id: \.self) { groupIndex in
                HStack {
                    ForEach(grouped[groupIndex].indices) { rowIndex in
                        grouped[groupIndex][rowIndex]
                    }
                }
            }
        }
    }
}

struct ComponentGroupedView_Previews: PreviewProvider {
    static var previews: some View {
        ComponentRokuDevices()
//        ComponentGroupedView(
//            Array(0...10).map({ i in
//                AnyView(Text("\(i)"))
//            })
//        )
    }
}
