/// Copies output from an output stream into an array
/// of stream split deltas.
///
/// Example using a splitter to split a stream of numbers:
///
///     let numberEmitter = EmitterStream<Int>()
///     let splitter = OutputStreamSplitter(numberEmitter)
///
///     var output: [Int] = []
///
///     splitter.split { int in
///         output.append(int)
///     }
///     splitter.split { int in
///         output.append(int)
///     }
///
///     numberEmitter.emit(1)
///     numberEmitter.emit(2)
///     numberEmitter.emit(3)
///
///     print(output) /// [1, 1, 2, 2, 3, 3]
///
public final class OutputStreamSplitter<O: OutputStream> {
    /// See OutputStream.outputStream
    let outputStream: O

    /// Split handlers can throw, we will report
    /// to the error stream
    public typealias Splits = (O.Output) throws -> ()

    /// Internal stream
    internal var _stream: BasicStream<O.Output>?

    /// The stored stream deltas
    public var splits: [Splits]

    /// Create a new stream splitter from an output stream
    public init(_ outputStream: O) {
        self.outputStream = outputStream
        splits = []
        _stream = outputStream.drain { output in
            for delta in self.splits {
                try delta(output)
            }
        }
    }

    /// Split the output stream to this new handler.
    public func split(closure: @escaping Splits) -> Self {
        self.splits.append(closure)
        return self
    }


    /// Sets this stream's error clsoure
    @discardableResult
    public func `catch`(onError: @escaping BasicStream<O.Output>.OnError) -> Self {
        _stream?.catch(onError: onError)
        return self
    }
}
