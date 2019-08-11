# Triple Buffer Generic Class

While Apple does a great job of explaining why a multi-buffering technique is useful to avoid acess conflicts with dynamic data it does not do a very good job making the code easy to use in projects. This may especially confuse people who do not understand how to manage memory in Swift.

As a response, I have extracted this technique into a generic class that will allow you to easily implement this in your design.

Here is how you use it:

~~~~
//On init
guard let buff = BasicMB<Int>(type: Int.self, maxBuffers: 3, count: 5, device: self.device) else {return nil}
uniformInts = buff

//In update loop

//Wait for GPU to finish reading a slot (recommend usage of a semaphore)
uniformInts.prepareForUpdatePostSemaphore()
for i in 0..<4
{
   uniformInts.update(dataIn: c, index: i)
   c = Int(arc4_random())
}
//Let the GPU know what offset to read from
encoder.setVertexBuffer(trippleBuffer.buffer(), offset: trippleBuffer.offset(), index: 0)
~~~~
