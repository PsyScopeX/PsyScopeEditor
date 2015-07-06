//
//  CGPoint.swift
//  PsyScopeEditor
//
//  Created by James on 16/09/2014.
//

extension CGPoint {
    static func distance(v : CGPoint, w : CGPoint) -> CGFloat {
        let a = Float(v.x - w.x)
        let b = Float(v.y - w.y)
        let sol = (a * a) + (b * b)
        return CGFloat(sqrt(sol))
    }
    
    static func minDistanceFromLineSegment(segA : CGPoint, segB : CGPoint, p: CGPoint) -> CGFloat {
        let p2 = CGPoint(x: segB.x - segA.x, y: segB.y - segA.y);
        let something = (p2.x*p2.x) + (p2.y*p2.y)
        var u = ((p.x - segA.x) * p2.x + (p.y - segA.y) * p2.y) / something;
        
        if (u > 1) {
            u = 1 }
        else if (u < 0) {
            u = 0 }
        
        let x = segA.x + u * p2.x;
        let y = segA.y + u * p2.y;
        
        let dx = x - p.x;
        let dy = y - p.y;
        
        let dist = sqrt(dx*dx + dy*dy);
        
        return dist;
    }
}
