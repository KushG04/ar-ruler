//
//  ViewController.swift
//  AR Ruler
//
//  Created by Kush Gupta on 8/8/24.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            if let query = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .any) {
                let results = sceneView.session.raycast(query)
                if let result = results.first {
                    addDot(at: result)
                }
            }
        }
    }

    func addDot(at result: ARRaycastResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        dotNode.position = SCNVector3(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    
    func calculate() {
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        let distance = sqrt(
            pow(end.position.x - start.position.x, 2) +
            pow(end.position.y - start.position.y, 2) +
            pow(end.position.z - start.position.z, 2)
        )
        
        updateText(text: "\(abs(distance))", atPosition: end.position)
    }
    
    func updateText(text: String, atPosition position: SCNVector3) {
        textNode.removeFromParentNode()
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.blue
        
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(x: position.x, y: position.y + 0.01, z: position.z)
        textNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        sceneView.scene.rootNode.addChildNode(textNode)
    }
}
