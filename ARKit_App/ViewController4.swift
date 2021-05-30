//
//  ViewController4.swift
//  ARKit_App
//
//  Created by 저스트비버 on 2021/05/28.
//

import UIKit
import RealityKit
import ARKit

class ViewController4: UIViewController {

    @IBOutlet var arView: ARView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController4")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        arView.session.delegate = self
        
        setupARView()
        
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
    }
    
    //MARK: Setup Methods
    func setupARView() {
        arView.automaticallyConfigureSession = false
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration)
    }
    
    //MARK: Object Placement
    @objc
    func handleTap(recognizer: UITapGestureRecognizer) {
        let locatoin = recognizer.location(in: arView)
        
        let results = arView.raycast(from: locatoin, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let firstResult = results.first {
            let anchor = ARAnchor(name: "blue", transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
        } else {
            print("Object placement failed -couldn't find surface.")
        }
    }
    
    func placeObject(named entityName: String, for anchor: ARAnchor) {
        let entity = try! ModelEntity.loadModel(named: entityName)
        
        entity.generateCollisionShapes(recursive: true)
        arView.installGestures([.rotation,.translation], for: entity)
        
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(entity)
        arView.scene.addAnchor(anchorEntity)
    }
    
    @IBAction func onClick_DM(_ sender: Any) {
        let vcName = self.storyboard?.instantiateViewController(withIdentifier: "ViewController3")
        vcName?.modalTransitionStyle = .coverVertical
        self.present(vcName!, animated: true, completion: nil)
    }
}

extension ViewController4: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == "blue" {
                placeObject(named: anchorName, for: anchor)
            }
        }
    }
}
