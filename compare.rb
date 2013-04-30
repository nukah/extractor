CHUNK_SIZE = 2**16
MULTIPLIER = 8
require 'benchmark'
def compare(old, recent)
  [old,recent].each { |file|
    abort("'#{file}' does not exist or not readable") unless File.exist?(file) && File.readable?(file)
  }

  removed = []
  added = []

  extractor = Proc.new do |fs1, fs2|
    old_file_chunk = fs1.next
    new_file_chunk = fs2.next

    #old_file_chunk.map! { |e| e.strip }
    #new_file_chunk.map! { |e| e.strip }
    added_files = new_file_chunk - old_file_chunk
    removed_files = old_file_chunk - new_file_chunk
    # added_files = [new_file_chunk, old_file_chunk].reduce(:-)
    # removed_files = [old_file_chunk, new_file_chunk].reduce(:-)

    [added_files, removed_files]

  end

  io1 = File.open(old, "r").each_slice(CHUNK_SIZE)
  io2 = File.open(recent, "r").each_slice(CHUNK_SIZE)

  #workers = File.size(old).fdiv(CHUNK_SIZE*MULTIPLIER).ceil

  loop do
    Fiber.new {
      puts "started new extract"
      old_file_chunk = io1.next
      new_file_chunk = io2.next
      added.push([new_file_chunk - old_file_chunk]).flatten!
      removed.push([old_file_chunk - new_file_chunk]).flatten!
      puts "finished"
    }.resume
  end

  [added, removed]
end

Benchmark.bm do |test|
  test.report { a,r = compare("filepaths.txt", "filepaths2.txt")
    puts "added:"
    puts a
    puts "removed:"
    puts r
  }
end