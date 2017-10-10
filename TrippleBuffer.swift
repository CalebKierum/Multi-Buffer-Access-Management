//
//  TrippleBuffer.swift
//  Trying Tripple Buffer
//
//  Created by Caleb Kierum on 9/26/17.
//  Copyright © 2017 Caleb Kierum. All rights reserved.
//

import Foundation
import Metal

class BasicMB<T>
{
    //iOS is safe with offsets of a multiple of 16 bytes however MacOS requires multiples of 256 bytes
    #if os(iOS)
    let idealOffset = 16
    #else
    let idealOffset = 256
    #endif
    
    var deviceBuffer:MTLBuffer

    
    var bufferIndex:Int = 0
    var bufferOffset:Int = 0
    let maxBuffers:Int
    let byteAllignedSize:Int
    let arrayCount:Int
    
    var data: UnsafeMutablePointer<T>
    var type: T.Type
    
    //Creates a multibuffer with maxBuffers slots taking count items per slot. Pass in MTLDevice to increase efficiency
    init?(type: T.Type, maxBuffers: Int, count: Int, device: MTLDevice?)
    {
        assert(count > 0, "Cant have a count of 0! There would be no data")
        
        
        self.maxBuffers = maxBuffers
        self.type = type
        arrayCount = count
        
        //If given a device use it otherwise make one
        var actualDevice = device
        if (actualDevice == nil)
        {actualDevice = MTLCreateSystemDefaultDevice()}
        
        //Round up to the nearest idealOffset multiple
        byteAllignedSize = (((MemoryLayout<T>.size * count) + (idealOffset - 1)) / (idealOffset)) * (idealOffset)

        guard let buffer = actualDevice!.makeBuffer(length:byteAllignedSize * maxBuffers, options:[MTLResourceOptions.storageModeShared]) else { return nil }
        deviceBuffer = buffer
            
        data = UnsafeMutableRawPointer(deviceBuffer.contents()).bindMemory(to:type.self, capacity:count)
    }
    
    //After the semaphore has triggered you are free to switch the CPU writing location
    func prepareForUpdatePostSemaphore()
    {
        bufferIndex = (bufferIndex + 1) % maxBuffers
        bufferOffset = byteAllignedSize * bufferIndex
        
        data = UnsafeMutableRawPointer(deviceBuffer.contents() + bufferOffset).bindMemory(to:type.self, capacity:arrayCount)
    }
    
    //This is an acceptable way to update data in the buffer although you would be advised to use create your own class specefic to the type you are working wtih
    func update(dataIn: T, index: Int = 0)
    {
        data[index] = dataIn
    }
    
    //Avoid running in release builds
    func reportAllValues()
    {
        let save = bufferOffset
        
        var string = ""
        for i in 0..<maxBuffers
        {
            bufferOffset = byteAllignedSize * i
            data = UnsafeMutableRawPointer(deviceBuffer.contents() + bufferOffset).bindMemory(to:type.self, capacity:arrayCount)
            string += "|"
            for p in 0..<arrayCount
            {
                string += String.init(describing: data[p])
                string += " "
            }
            string += "|"
        }
        print(string)
        
        bufferOffset = save
        data = UnsafeMutableRawPointer(deviceBuffer.contents() + bufferOffset).bindMemory(to:type.self, capacity:arrayCount)
    }
}


