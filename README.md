# Triple Buffer Generic Class

![Tripple Buffering](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/MTLBestPracticesGuide/Art/ResourceManagement_TripleBuffering_2x.png)

Due to confusion around memory management in Swift it may often be difficult for developers to implement the suggested practices that allow for significantly better CPU and GPU usage and 2x the performance when involving dynamic data structures.

I have the suggested practices into a generic class that will allow you to easily implement this in your design.

Here is how you use it:

~~~~
//On init
let buff = BasicMB<Int>(type: Int.self, maxBuffers: 3, count: 5, device: self.device) else {return nil}

//In update loop

//Wait for GPU to finish reading a slot (recommend usage of a semaphore)
buff.prepareForUpdatePostSemaphore()
for i in 0..<4
{
   // Where 'c' is the data you want to update at that index
   uniformInts.update(dataIn: c, index: i)
}
//Let the GPU know what offset to read from

~~~~
