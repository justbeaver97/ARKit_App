//
//  ViewController3.swift
//  ARKit_App
//
//  Created by 저스트비버 on 2021/05/28.
//
//  From AR-Ruler-Main
//  reference: https://github.com/jessangel79/AR-Ruler

import UIKit
import SceneKit
import ARKit

final class ViewController3: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private var sceneView: ARSCNView!
    
    // MARK: - Properties
    
    private var dotNodes = [SCNNode]()
    private var textNode = SCNNode()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
    }
    
    @IBAction func onClick_Placement(_ sender: Any) {
        let vcName = self.storyboard?.instantiateViewController(withIdentifier: "ViewController4")
        vcName?.modalTransitionStyle = .coverVertical
        self.present(vcName!, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - Methods
    
    private func addDot(at hitResult: ARRaycastResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotGeometry.materials = [material]
        let dotNode = SCNNode(geometry: dotGeometry)
        dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                      hitResult.worldTransform.columns.3.y,
                                      hitResult.worldTransform.columns.3.z)
        dotNodes.append(dotNode)
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    
    private func calculate() {
        let startPosition = dotNodes[0].position
        let endPosition = dotNodes[1].position
        print(startPosition)
        print(endPosition)
//        distance = √ ((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2)
        let distance = sqrt(
            pow(endPosition.x - startPosition.x, 2) +
            pow(endPosition.y - startPosition.y, 2) +
            pow(endPosition.z - startPosition.z, 2)
        )
        let textFormatted = String(format: "%.2f", (abs(distance * 100))) + " cm"
        updateText(text: textFormatted, atPosition: endPosition)
    }
    
    private func updateText(text: String, atPosition position: SCNVector3) {
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    private func refreshDotNodes() {
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
            textNode.removeFromParentNode()
        }
    }
}

// MARK: - ARSCNViewDelegateMethods

extension ViewController3: ARSCNViewDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        refreshDotNodes()
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            guard let query = sceneView.raycastQuery(from: touchLocation,
                                                     allowing: .estimatedPlane,
                                                     alignment: .any) else { return }
            let hitTestResults = sceneView.session.raycast(query)
            guard let hitResult = hitTestResults.first else {
                print("No surface detected")
                return
            }
            addDot(at: hitResult)
        }
    }
}
